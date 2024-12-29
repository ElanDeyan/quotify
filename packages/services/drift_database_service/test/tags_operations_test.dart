import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:drift_database_service/src/database/app_database.dart';
import 'package:drift_database_service/src/exceptions/database_errors.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotify_utils/quotify_utils.dart';
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
    test('without any entry, should return empty list', () async {
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
    final sampleEntry = TagEntry(label: NonBlankString(faker.lorem.word()));

    test('without data, should add and return Ok with the data', () async {
      expect(database.allTags, completion(isEmpty));

      final result = await database.createTag(sampleEntry);

      expect(result, isA<Ok<TagTable>>());
      final TagTable(:label) = result.asOk.value;

      expect(label, equals(sampleEntry.label));

      expect(database.allTags, completion(hasLength(1)));
    });

    test(
      'having a tag with same label, will create a new one, '
      'but with different Id',
      () async {
        final sampleEntry = TagEntry(label: NonBlankString(faker.lorem.word()));

        final firstAdded = await database.createTag(sampleEntry);
        final secondAdded = await database.createTag(sampleEntry);

        expect(firstAdded, isA<Ok<TagTable>>());
        expect(secondAdded, isA<Ok<TagTable>>());

        expect(
          firstAdded.asOk.value.label,
          equals(secondAdded.asOk.value.label),
        );

        expect(firstAdded.asOk.value.id, isNot(secondAdded.asOk.value.id));
      },
    );
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
        sampleEntry = TagEntry(label: NonBlankString(faker.lorem.word()));

        addedTagTable = (await database.createTag(sampleEntry)).asOk.value;
      });

      test(
          'and the existent Id was passed, return the TagTable '
          'with the passed id', () async {
        final maybeTag =
            await database.getTagById(Id(addedTagTable.id.toNatural()));

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
      late TagEntry firstEntry;
      late TagEntry secondEntry;
      late TagTable initialAdded;

      setUp(() async {
        firstEntry = TagEntry(label: NonBlankString(faker.lorem.word()));
        secondEntry = TagEntry(label: NonBlankString(faker.lorem.word()));

        initialAdded = (await database.createTag(firstEntry)).asOk.value;
        await Future.delayed(
          const Duration(seconds: 1),
          () {
            // Needed to give time before the next updated operation
          },
        );
      });

      test(
        'should update the label and updatedAt, but keep the Id and createdAt',
        () async {
          final result = await database.updateTag(
            Id(initialAdded.id.toNatural()),
            secondEntry,
          );

          expect(result, isA<Ok<TagTable>>());

          final TagTable(:id, :label, :createdAt, :updatedAt) =
              result.asOk.value;

          expect(id, equals(initialAdded.id));
          expect(createdAt, equals(initialAdded.createdAt));

          expect(
            label,
            allOf([
              isNot(initialAdded.label),
              equals(secondEntry.label),
            ]),
          );
          expect(updatedAt, isNot(initialAdded.updatedAt));
        },
      );

      test(
          'but inexistent Id was passed, should return a failure '
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

        final result = await database.updateTag(
          nonExistentId,
          secondEntry,
        );

        expect(result, isA<Failure<TagTable>>());
        expect(
          result.asFailure.failure,
          equals(DatabaseErrors.cannotUpdateEntry),
        );
      });
    });
  });
}
