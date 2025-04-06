import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:drift_database_service/src/database/app_database.dart';
import 'package:drift_database_service/src/exceptions/database_errors.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/repositories/tag_entry.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });
  tearDown(() async {
    await database.close();
  });

  group('allTags', () {
    test('without any entry, should return empty list', () {
      expect(database.allTags, completion(isEmpty));
    });

    test('with entry, should return a positive length', () async {
      await database
          .into(database.tags)
          .insert(TagsCompanion(label: Value(faker.lorem.word())));

      expect(database.allTags, completion(hasLength(1)));
    });
  });

  group('createTag', () {
    final sampleEntry = HalfTagEntry(label: NonBlankString(faker.lorem.word()));

    test('without data, should add and return Ok with the data', () async {
      expect(database.allTags, completion(isEmpty));

      final result = await database.createTag(sampleEntry);

      expect(result, isA<Ok<TagTable, DatabaseErrors>>());
      final TagTable(:label) = result.asOk.value;

      expect(label, equals(sampleEntry.label));

      expect(database.allTags, completion(hasLength(1)));
    });

    test('having a tag with same label, will create a new one, '
        'but with different Id', () async {
      final sampleEntry = HalfTagEntry(
        label: NonBlankString(faker.lorem.word()),
      );

      final firstAdded = await database.createTag(sampleEntry);
      final secondAdded = await database.createTag(sampleEntry);

      expect(firstAdded, isA<Ok<TagTable, DatabaseErrors>>());
      expect(secondAdded, isA<Ok<TagTable, DatabaseErrors>>());

      expect(firstAdded.asOk.value.label, equals(secondAdded.asOk.value.label));

      expect(firstAdded.asOk.value.id, isNot(secondAdded.asOk.value.id));
    });

    test('with a full entry, and existing id, should not replace it', () async {
      final sampleEntry = HalfTagEntry(
        label: NonBlankString(faker.lorem.word()),
      );

      final addedTag = (await database.createTag(sampleEntry)).asOk.value;

      final fullEntryWithSameId = FullTagEntry(
        label: NonBlankString(faker.lorem.word()),
        id: Id(Natural((await database.allTags).single.id)),
      );

      final result = await database.createTag(fullEntryWithSameId);

      expect(result, isA<Failure<TagTable, DatabaseErrors>>());
      expect(database.allTags, completion(hasLength(1)));
      expect(database.allTags, completion([addedTag]));
    });
  });

  group('getTagById', () {
    group('with empty database', () {
      test('should return null', () async {
        expect(database.allTags, completion(isEmpty));

        final sampleId = Id(faker.randomGenerator.integer(50).toNatural());

        final result = await database.getTagById(sampleId);

        expect(result, isNull);
      });
    });

    group('with an entry', () {
      late TagTable addedTagTable;
      late TagEntry sampleEntry;
      setUp(() async {
        sampleEntry = HalfTagEntry(label: NonBlankString(faker.lorem.word()));

        addedTagTable = (await database.createTag(sampleEntry)).asOk.value;
      });

      test('and the existent Id was passed, return the TagTable '
          'with the passed id', () async {
        final maybeTag = await database.getTagById(
          Id(addedTagTable.id.toNatural()),
        );

        expect(maybeTag, equals(addedTagTable));
      });

      test('and a non-existent id was passed, should return null', () async {
        final nonExistentId = Id(Natural(addedTagTable.id + 1));
        expect(
          await database.allTags,
          predicate(
            (List<TagTable> tags) =>
                !tags.map((tag) => tag.id).contains(nonExistentId.toInt()),
          ),
        );

        final maybeTag = await database.getTagById(nonExistentId);

        expect(maybeTag, isNull);
      });
    });
  });

  group('updateTag', () {
    group('with existent tag', () {
      late HalfTagEntry firstEntry;
      late FullTagEntry secondEntry;
      late TagTable initialAdded;

      setUp(() async {
        firstEntry = HalfTagEntry(label: NonBlankString(faker.lorem.word()));

        initialAdded = (await database.createTag(firstEntry)).asOk.value;
        await Future.delayed(const Duration(seconds: 1), () {
          // Needed to give time before the next updated operation
        });

        secondEntry = FullTagEntry(
          id: Id(initialAdded.id.toNatural()),
          label: NonBlankString(faker.lorem.word()),
        );
      });

      test(
        'should update the label and updatedAt, but keep the Id and createdAt',
        () async {
          final result = await database.updateTag(secondEntry);

          expect(result, isA<Ok<TagTable, DatabaseErrors>>());

          final TagTable(:id, :label, :createdAt, :updatedAt) =
              result.asOk.value;

          expect(id, equals(initialAdded.id));
          expect(createdAt, equals(initialAdded.createdAt));

          expect(
            label,
            allOf([isNot(initialAdded.label), equals(secondEntry.label)]),
          );
          expect(updatedAt, isNot(initialAdded.updatedAt));
        },
      );

      test('but inexistent Id was passed, should return a failure '
          'with DatabaseErrors.cannotUpdateEntry', () async {
        final nonExistentId = Id(Natural(initialAdded.id + 1));

        expect(
          database.allTags,
          completion(
            predicate(
              (List<TagTable> tags) =>
                  !tags.map((tag) => tag.id).contains(nonExistentId.toInt()),
            ),
          ),
        );

        secondEntry = FullTagEntry(label: secondEntry.label, id: nonExistentId);
        final result = await database.updateTag(secondEntry);

        expect(result, isA<Failure<TagTable, DatabaseErrors>>());
        expect(result.asFailure.failure, equals(DatabaseErrors.notFoundId));
      });
    });
  });

  group('deleteTag', () {
    late TagEntry firstEntry;
    late TagTable initialAdded;

    setUp(() async {
      firstEntry = HalfTagEntry(label: NonBlankString(faker.lorem.word()));
      initialAdded = (await database.createTag(firstEntry)).asOk.value;
    });

    test('delete existent id should remove it and return it as a Ok', () async {
      final initialTagsQuantity = (await database.allTags).length;

      final result = await database.deleteTag(Id(initialAdded.id.toNatural()));

      expect(result, isA<Ok<TagTable, DatabaseErrors>>());
      expect(result.asOk.value, equals(initialAdded));

      final actualTagsQuantity = (await database.allTags).length;
      expect(actualTagsQuantity, equals(initialTagsQuantity - 1));
    });

    test(
      'delete non-existent Id should return Failure with notFoundId',
      () async {
        final initialTagsQuantity = (await database.allTags).length;

        final nonExistentId = Id(Natural(initialAdded.id + 1));

        expect(
          database.allTags,
          completion(
            predicate(
              (List<TagTable> tags) =>
                  !tags.map((tag) => tag.id).contains(nonExistentId.toInt()),
            ),
          ),
        );

        final result = await database.deleteTag(nonExistentId);

        expect(result, isA<Failure<TagTable, DatabaseErrors>>());
        expect(result.asFailure.failure, equals(DatabaseErrors.notFoundId));

        final actualTagsQuantity = (await database.allTags).length;
        expect(actualTagsQuantity, equals(initialTagsQuantity));
      },
    );
  });

  group('clearAllTags', () {
    test('should return Ok and have 0 tags in the table', () async {
      for (var i = 0; i < 10; i++) {
        await database.createTag(
          HalfTagEntry(label: NonBlankString(faker.lorem.word())),
        );
      }

      final result = await database.clearAllTags();

      expect(result, isA<Ok<(), DatabaseErrors>>());
      expect(database.allTags, completion(hasLength(isZero)));
    });
  });

  group('getTagsByIds', () {
    test('with empty Id list, should return an empty list', () {
      expect(database.getTagsWithIds([]), completion(isEmpty));
    });

    test('with all ids existing, should return exactly N items', () async {
      for (var i = 0; i < 10; i++) {
        await database.createTag(
          HalfTagEntry(label: NonBlankString(faker.lorem.word())),
        );
      }

      final tags = await database.allTags;
      final allIds = tags.map((tag) => Id(tag.id.toNatural()));

      final tagsWithIds = await database.getTagsWithIds(allIds);

      expect(tagsWithIds, equals({...tags}));
    });

    test(
      'with a non-existent id, should just ignore it and return founded ones',
      () async {
        final missingId = Id(50.toNatural());
        for (var i = 0; i < 10; i++) {
          await database.createTag(
            HalfTagEntry(label: NonBlankString(faker.lorem.word())),
          );
        }

        final tags = await database.allTags;
        final idsInDatabase = tags.map((tag) => Id(tag.id.toNatural()));

        expect(idsInDatabase.contains(missingId), isFalse);

        final foundTags = await database.getTagsWithIds([
          ...idsInDatabase,
          missingId,
        ]);

        expect(foundTags.map((e) => e.id).contains(missingId.toInt()), isFalse);
        expect(foundTags, equals({...tags}));
      },
    );
  });
}
