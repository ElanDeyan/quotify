import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:drift_database_service/src/database/app_database.dart';
import 'package:drift_database_service/src/exceptions/database_errors.dart';
import 'package:drift_database_service/src/extensions/quote_entry_extension.dart';
import 'package:drift_database_service/src/extensions/quote_table_extension.dart';
import 'package:drift_database_service/src/extensions/tag_table_extension.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotes_repository/repositories/quote_entry.dart';
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

  group('allQuotes', () {
    test('without any entry, should return empty list', () {
      expect(database.allQuotes, completion(isEmpty));
    });

    test('with entry, should return a positive length', () async {
      await database
          .into(database.quotes)
          .insert(
            PartialQuoteEntry(
              content: NonBlankString(faker.lorem.sentences(10).join(' ')),
              author: NonBlankString(faker.person.name()),
              isFavorite: true,
              tags: {},
            ).toQuotesCompanion(),
          );

      expect(database.allQuotes, completion(hasLength(1)));
    });
  });

  group('createQuote', () {
    final sampleEntry = PartialQuoteEntry(
      content: NonBlankString(faker.lorem.sentence()),
      author: NonBlankString(faker.person.name()),
    );

    test('without data, should add and return Ok with the data', () async {
      expect(database.allQuotes, completion(isEmpty));

      final result = await database.createQuote(sampleEntry);

      expect(result, isA<Ok<QuoteTable, DatabaseErrors>>());
      final QuoteTable(:content, :author) = result.asOk.value;

      expect(content, equals(sampleEntry.content));
      expect(author, equals(sampleEntry.author));

      expect(database.allQuotes, completion(hasLength(1)));
    });

    test('having a quote with same properties, will create a new one, '
        'but with different Id', () async {
      final sampleEntry = PartialQuoteEntry(
        content: NonBlankString(faker.lorem.sentence()),
        author: NonBlankString(faker.person.name()),
      );

      final firstAdded = await database.createQuote(sampleEntry);
      final secondAdded = await database.createQuote(sampleEntry);

      expect(firstAdded, isA<Ok<QuoteTable, DatabaseErrors>>());
      expect(secondAdded, isA<Ok<QuoteTable, DatabaseErrors>>());

      expect(
        firstAdded.asOk.value.content,
        equals(secondAdded.asOk.value.content),
      );
      expect(
        firstAdded.asOk.value.author,
        equals(secondAdded.asOk.value.author),
      );

      expect(firstAdded.asOk.value.id, isNot(secondAdded.asOk.value.id));
    });

    test('with a full entry, and existing id, should not replace it', () async {
      final samplePartialEntry = PartialQuoteEntry(
        content: NonBlankString(faker.lorem.sentence()),
        author: NonBlankString(faker.person.name()),
      );

      final addedQuote =
          (await database.createQuote(samplePartialEntry)).asOk.value;

      final fullEntryWithSameId = FullQuoteEntry(
        content: NonBlankString(faker.lorem.sentence()),
        author: NonBlankString(faker.person.name()),
        id: Id(addedQuote.id.toNatural()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now().add(const Duration(minutes: 1)),
      );

      final result = await database.createQuote(fullEntryWithSameId);

      expect(result, isA<Failure<QuoteTable, DatabaseErrors>>());
      expect(
        result.asFailure.failure,
        equals(DatabaseErrors.cannotCreateEntry),
      );
      expect(database.allQuotes, completion(hasLength(1)));

      // Converting to Quote model to compare tags set by value
      final addedQuoteAsQuoteModel = addedQuote.toQuoteModel();
      final singleQuoteTableAsQuoteModel =
          (await database.allQuotes).single.toQuoteModel();
      expect(singleQuoteTableAsQuoteModel, addedQuoteAsQuoteModel);
    });
  });

  group('getQuoteById', () {
    group('with empty database', () {
      test('should return null', () async {
        expect(database.allQuotes, completion(isEmpty));

        final sampleId = Id(faker.randomGenerator.integer(50).toNatural());

        final result = await database.getQuoteById(sampleId);

        expect(result, isNull);
      });
    });

    group('with an entry', () {
      late QuoteTable addedQuoteTable;
      late PartialQuoteEntry sampleEntry;
      setUp(() async {
        sampleEntry = PartialQuoteEntry(
          content: NonBlankString(faker.lorem.sentences(5).join(' ')),
          author: NonBlankString(faker.person.name()),
        );

        addedQuoteTable = (await database.createQuote(sampleEntry)).asOk.value;
      });

      test('and the existent Id was passed, return the QuoteTable '
          'with the passed id', () async {
        final quoteOrNull = await database.getQuoteById(
          Id(addedQuoteTable.id.toNatural()),
        );

        expect(quoteOrNull, isNotNull);
        expect(quoteOrNull?.id, equals(addedQuoteTable.id));

        // Converting to Quote model to compare tags set by value
        final addedQuoteTableAsQuoteModel = addedQuoteTable.toQuoteModel();
        final returnedQuoteTableAsQuoteModel = quoteOrNull!.toQuoteModel();

        expect(
          addedQuoteTableAsQuoteModel,
          equals(returnedQuoteTableAsQuoteModel),
        );
      });

      test('and a non-existent id was passed, should return null', () async {
        final nonExistentId = Id(Natural(addedQuoteTable.id + 1));
        expect(
          await database.allQuotes,
          predicate(
            (List<QuoteTable> quotes) =>
                !quotes
                    .map((quote) => quote.id)
                    .contains(nonExistentId.toInt()),
          ),
        );

        final quoteOrNull = await database.getQuoteById(nonExistentId);

        expect(quoteOrNull, isNull);
      });
    });
  });

  group('updateQuote', () {
    group('with existent quote', () {
      late PartialQuoteEntry firstEntry;
      late FullQuoteEntry secondEntry;
      late Quote initialAdded;

      setUp(() async {
        firstEntry = PartialQuoteEntry(
          content: NonBlankString(faker.lorem.sentence()),
          author: NonBlankString(faker.person.name()),
        );

        initialAdded =
            (await database.createQuote(firstEntry)).asOk.value.toQuoteModel();
        await Future.delayed(const Duration(seconds: 1), () {
          // Needed to give time before the next updated operation
        });

        secondEntry = FullQuoteEntry(
          content: NonBlankString(faker.lorem.sentence()),
          author: NonBlankString(faker.person.name()),
          id: initialAdded.id,
          createdAt: initialAdded.createdAt,
          updatedAt: DateTime.now(),
        );
      });

      test(
        'should update the other fields, but keep the Id and createdAt',
        () async {
          final result = await database.updateQuote(secondEntry);

          expect(result, isA<Ok<QuoteTable, DatabaseErrors>>());

          final Quote(:id, :content, :author, :createdAt, :updatedAt) =
              result.asOk.value.toQuoteModel();

          expect(id, equals(initialAdded.id));
          expect(createdAt, equals(initialAdded.createdAt));
          expect(updatedAt, isNot(initialAdded.updatedAt));

          expect(content, isNot(initialAdded.content));
          expect(author, isNot(initialAdded.author));
        },
      );

      test('but inexistent Id was passed, should return a failure '
          'with DatabaseErrors.cannotUpdateEntry', () async {
        final nonExistentId = Id(Natural(initialAdded.id.toInt() + 1));

        expect(
          database.allQuotes,
          completion(
            predicate(
              (List<QuoteTable> quotes) =>
                  !quotes
                      .map((quote) => quote.id)
                      .contains(nonExistentId.toInt()),
            ),
          ),
        );

        secondEntry = FullQuoteEntry(
          content: NonBlankString(faker.lorem.sentence()),
          author: NonBlankString(faker.person.name()),
          id: nonExistentId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now().add(const Duration(minutes: 1)),
        );

        final result = await database.updateQuote(secondEntry);

        expect(result, isA<Failure<QuoteTable, DatabaseErrors>>());
        expect(result.asFailure.failure, equals(DatabaseErrors.notFoundId));
      });
    });
  });

  group('deleteTag', () {
    late PartialQuoteEntry firstEntry;
    late Quote initialAdded;

    setUp(() async {
      firstEntry = PartialQuoteEntry(
        content: NonBlankString(faker.lorem.sentence()),
        author: NonBlankString(faker.person.name()),
      );
      initialAdded =
          (await database.createQuote(firstEntry)).asOk.value.toQuoteModel();
    });

    test('delete existent id should remove it and return it as a Ok', () async {
      final initialQuotesQuantity = (await database.allQuotes).length;

      final result = await database.deleteQuote(initialAdded.id);

      expect(result, isA<Ok<QuoteTable, DatabaseErrors>>());
      expect(result.asOk.value.toQuoteModel(), equals(initialAdded));

      final actualQuotesQuantity = (await database.allQuotes).length;
      expect(actualQuotesQuantity, equals(initialQuotesQuantity - 1));
    });

    test(
      'delete non-existent Id should return Failure with notFoundId',
      () async {
        final initialQuotesQuantity = (await database.allQuotes).length;

        final nonExistentId = Id(Natural(initialAdded.id.toInt() + 1));

        expect(
          database.allQuotes,
          completion(
            predicate(
              (List<QuoteTable> quotes) =>
                  !quotes
                      .map((quote) => quote.id)
                      .contains(nonExistentId.toInt()),
            ),
          ),
        );

        final result = await database.deleteQuote(nonExistentId);

        expect(result, isA<Failure<QuoteTable, DatabaseErrors>>());
        expect(result.asFailure.failure, equals(DatabaseErrors.notFoundId));

        final actualQuotesQuantity = (await database.allQuotes).length;
        expect(actualQuotesQuantity, equals(initialQuotesQuantity));
      },
    );
  });

  group('clearAllQuotes', () {
    test('should return Ok and have 0 quotes in the table', () async {
      for (var i = 0; i < 10; i++) {
        await database.createQuote(
          PartialQuoteEntry(
            content: NonBlankString(faker.lorem.sentence()),
            author: NonBlankString(faker.person.name()),
          ),
        );
      }

      final result = await database.clearAllQuotes();

      expect(result, isA<Ok<(), DatabaseErrors>>());
      expect(database.allQuotes, completion(hasLength(isZero)));
    });

    test('should return Ok even if table is empty and '
        'have 0 quotes in the table', () async {
      final result = await database.clearAllQuotes();

      expect(result, isA<Ok<(), DatabaseErrors>>());
      expect(database.allQuotes, completion(hasLength(isZero)));
    });
  });

  group('getQuotesByIds', () {
    test('with empty Id list, should return an empty list', () {
      expect(database.getQuotesWithIds([]), completion(isEmpty));
    });

    test('with all ids existing, should return exactly N items', () async {
      for (var i = 0; i < 10; i++) {
        await database.createQuote(
          PartialQuoteEntry(
            content: NonBlankString(faker.lorem.sentence()),
            author: NonBlankString(faker.person.name()),
          ),
        );
      }

      final quotes =
          (await database.allQuotes).map((e) => e.toQuoteModel()).toSet();
      final allIds = quotes.map((quote) => quote.id);

      final quotesWithIds =
          (await database.getQuotesWithIds(
            allIds,
          )).map((e) => e.toQuoteModel()).toSet();

      expect(quotesWithIds, equals({...quotes}));
    });

    test(
      'with a non-existent id, should just ignore it and return founded ones',
      () async {
        final missingId = Id(50.toNatural());
        for (var i = 0; i < 10; i++) {
          await database.createQuote(
            PartialQuoteEntry(
              content: NonBlankString(faker.lorem.sentence()),
              author: NonBlankString(faker.person.name()),
            ),
          );
        }

        final quotes =
            (await database.allQuotes).map((e) => e.toQuoteModel()).toSet();
        final idsInDatabase = quotes.map((quote) => quote.id);

        expect(idsInDatabase.contains(missingId), isFalse);

        final foundQuotes =
            (await database.getQuotesWithIds([
              ...idsInDatabase,
              missingId,
            ])).map((e) => e.toQuoteModel()).toSet();

        expect(foundQuotes.map((e) => e.id).contains(missingId), isFalse);
        expect(foundQuotes, equals({...quotes}));
      },
    );
  });

  group('getQuotesWithTagId', () {
    test('without quotes, return empty set', () async {
      final sampleId = Id(Natural(faker.randomGenerator.integer(50)));

      expect(database.allQuotes, completion(isEmpty));

      final quotesWithTag = await database.getQuotesWithTagId(sampleId);

      expect(quotesWithTag, isEmpty);
    });

    test('with inexistent tag id, simply return empty', () async {
      for (var i = 0; i < 10; i++) {
        await database.createQuote(
          PartialQuoteEntry(
            content: NonBlankString(faker.lorem.sentence()),
            author: NonBlankString(faker.person.name()),
          ),
        );
      }

      expect(database.allTags, completion(isEmpty));

      final sampleId = Id(Natural(faker.randomGenerator.integer(50)));

      final quotesWithInexistentTagId = await database.getQuotesWithTagId(
        sampleId,
      );

      expect(quotesWithInexistentTagId, isEmpty);
    });

    test('should return all quotes that have specific tag id', () async {
      final sampleIdForTag = Id(Natural(faker.randomGenerator.integer(50)));
      final addedTag = await database
          .createTag(
            FullTagEntry(
              label: NonBlankString(faker.lorem.word()),
              id: sampleIdForTag,
            ),
          )
          .then((value) => value.asOk.value);

      final addedTagAsTagModel = addedTag.toTag();

      for (var i = 0; i < 10; i++) {
        await database.createQuote(
          PartialQuoteEntry(
            content: NonBlankString(faker.lorem.sentence()),
            author: NonBlankString(faker.person.name()),
            tags: i.isEven ? const {} : {addedTagAsTagModel},
          ),
        );
      }

      const evenNumbersFromZeroToNine = 5;

      final quotesWithTagId = await database.getQuotesWithTagId(sampleIdForTag);

      expect(quotesWithTagId, hasLength(evenNumbersFromZeroToNine));
      expect(
        quotesWithTagId.every(
          (element) => element.tags.contains(addedTagAsTagModel),
        ),
        isTrue,
      );
    });
  });
}
