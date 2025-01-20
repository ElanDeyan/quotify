import 'dart:convert';
import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotes_repository/logic/models/quote_errors.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/logic/models/tag_errors.dart';
import 'package:tags_repository/logic/models/tag_model_errors.dart';

void main() {
  group('equality', () {
    test('when all properties are equal, both are equal', () {
      final content = NonBlankString(faker.lorem.sentences(3).join(' '));
      final author = NonBlankString(faker.person.name());
      final createdAt = faker.date.dateTime(maxYear: 2024);
      final updatedAt = faker.date.dateTime(minYear: 2025);
      final tags = {
        Tag(id: Id(5.toNatural()), label: NonBlankString(faker.lorem.word())),
        Tag(id: Id(6.toNatural()), label: NonBlankString(faker.lorem.word())),
        Tag(id: Id(7.toNatural()), label: NonBlankString(faker.lorem.word())),
      };

      final sample1 = Quote(
        id: Id(10.toNatural()),
        content: content,
        author: author,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
      );
      final sample2 = Quote(
        id: Id(10.toNatural()),
        content: content,
        author: author,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
      );

      expect(sample1, equals(sample2));
      expect(sample1.hashCode, equals(sample2.hashCode));
    });

    test('when tags are different, quotes are different', () {
      final content = NonBlankString(faker.lorem.sentences(3).join(' '));
      final author = NonBlankString(faker.person.name());
      final createdAt = faker.date.dateTime(maxYear: 2024);
      final updatedAt = faker.date.dateTime(minYear: 2025);
      final tags1 = {
        Tag(id: Id(5.toNatural()), label: NonBlankString(faker.lorem.word())),
      };
      final tags2 = <Tag>{};

      final sample1 = Quote(
        id: Id(10.toNatural()),
        content: content,
        author: author,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags1,
      );
      final sample2 = Quote(
        id: Id(10.toNatural()),
        content: content,
        author: author,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags2,
      );

      expect(sample1, isNot(sample2));
      expect(sample1.hashCode, isNot(sample2.hashCode));
    });
  });
  group('fromMap', () {
    group('when map is wrong', () {
      test('like a negative ID should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': -1,
          'content': faker.lorem.words(5).join(' '),
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': faker.date.dateTime(),
          'updatedAt': faker.date.dateTime(),
          'tags': [],
        };

        final result = Quote.fromMap(quoteMap);
        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(QuoteErrors.invalidMapRepresentation),
        );
      });
      test('like empty content should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': 1,
          'content': '',
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': faker.date.dateTime(),
          'updatedAt': faker.date.dateTime(),
          'tags': [],
        };

        final result = Quote.fromMap(quoteMap);
        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(QuoteErrors.invalidMapRepresentation),
        );
      });
      test('like empty author should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': 1,
          'content': faker.lorem.sentences(5).join(' '),
          'author': '',
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': faker.date.dateTime(),
          'updatedAt': faker.date.dateTime(),
          'tags': [],
        };

        final result = Quote.fromMap(quoteMap);
        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(QuoteErrors.invalidMapRepresentation),
        );
      });
      test('like invalid sourceUri should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': 1,
          'content': faker.lorem.sentences(5).join(' '),
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.randomGenerator.string(10),
          'isFavorite': Random().nextBool(),
          'createdAt': faker.date.dateTime(),
          'updatedAt': faker.date.dateTime(),
          'tags': [],
        };

        final result = Quote.fromMap(quoteMap);
        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(QuoteErrors.invalidMapRepresentation),
        );
      });
      test('like invalid createdAt should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': 1,
          'content': faker.lorem.sentences(5).join(' '),
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': faker.randomGenerator.string(10),
          'updatedAt': faker.date.dateTime(),
          'tags': [],
        };

        final result = Quote.fromMap(quoteMap);
        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(QuoteErrors.invalidMapRepresentation),
        );
      });
      test('like invalid updatedAt should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': 1,
          'content': faker.lorem.sentences(5).join(' '),
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': faker.date.dateTime(),
          'updatedAt': faker.randomGenerator.string(10),
          'tags': [],
        };
        final result = Quote.fromMap(quoteMap);
        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(QuoteErrors.invalidMapRepresentation),
        );
      });
      test('like updatedAt before createdAt should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': 1,
          'content': faker.lorem.sentences(5).join(' '),
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': DateTime(2025, 1, 5).toIso8601String(),
          'updatedAt': DateTime(2025, 1, 4).toIso8601String(),
          'tags': [],
        };

        final result = Quote.fromMap(quoteMap);

        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(QuoteErrors.updatedAtDateBeforeCreatedAt),
        );
      });
      test('like at least one wrong tag map should return a Failure', () {
        final quoteMap = <String, Object?>{
          'id': 1,
          'content': faker.lorem.sentences(5).join(' '),
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': DateTime(2025, 1, 5).toIso8601String(),
          'updatedAt': DateTime(2025, 1, 6).toIso8601String(),
          'tags': [
            for (var i = 0; i < 3; i++)
              Tag(
                id: Id(Natural(10)),
                label: NonBlankString(faker.lorem.word()),
              ).toMap(),
            {
              'id': -1,
              'label': '',
            },
          ],
        };

        final result = Quote.fromMap(quoteMap);

        expect(result, isA<Failure<Quote>>());
        expect(
          result.asFailure.failure,
          equals(TagModelErrors.invalidMapRepresentation),
        );
      });
    });

    group('when map is valid', () {
      test('should return Ok with a quote', () {
        final sampleQuote = <String, Object?>{
          'id': 1,
          'content': faker.lorem.sentences(5).join(' '),
          'author': faker.person.name(),
          'source': faker.lorem.word(),
          'sourceUri': faker.internet.httpsUrl(),
          'isFavorite': Random().nextBool(),
          'createdAt': DateTime(2025, 1, 5).toIso8601String(),
          'updatedAt': DateTime(2025, 1, 6).toIso8601String(),
          'tags': [
            for (var i = 0; i < 3; i++)
              Tag(
                id: Id(Natural(10)),
                label: NonBlankString(faker.lorem.word()),
              ).toMap(),
          ],
        };

        final result = Quote.fromMap(sampleQuote);

        expect(result, isA<Ok<Quote>>());
      });
    });
  });

  group('fromJsonString', () {
    test('should return a valid Quote when JSON string is correct', () {
      final jsonString = jsonEncode({
        'id': 1,
        'content': 'Sample content',
        'author': 'Author',
        'source': 'Source',
        'sourceUri': 'https://example.com',
        'isFavorite': true,
        'createdAt': '2023-01-01T00:00:00.000Z',
        'updatedAt': '2023-01-02T00:00:00.000Z',
        'tags': [
          {'id': 1, 'label': 'Tag1'},
          {'id': 2, 'label': 'Tag2'},
        ],
      });

      final result = Quote.fromJsonString(jsonString);

      expect(result, isA<Ok<Quote>>());
    });

    test('should return Failure when JSON string is invalid', () {
      const jsonString = 'invalid_json';

      final result = Quote.fromJsonString(jsonString);

      expect(result, isA<Failure<Quote>>());
      expect(result.asFailure.failure, QuoteErrors.invalidJsonString);
    });

    test('should return Failure when JSON does not represent a map', () {
      final jsonString = jsonEncode([1, 2, 3]);

      final result = Quote.fromJsonString(jsonString);

      expect(result, isA<Failure<Quote>>());
      expect(result.asFailure.failure, QuoteErrors.invalidJsonString);
    });
  });

  test('toMap generates valid map', () {
    final sampleQuote = Quote(
      id: Id(10.toNatural()),
      content: NonBlankString(faker.lorem.sentences(3).join(' ')),
      author: NonBlankString(faker.person.name()),
      createdAt: faker.date.dateTime(maxYear: 2024),
      updatedAt: faker.date.dateTime(minYear: 2025),
      tags: {
        Tag(id: Id(5.toNatural()), label: NonBlankString(faker.lorem.word())),
      },
    );

    final quoteAsMap = sampleQuote.toMap();

    expect(Quote.fromMap(quoteAsMap).asOk.value, sampleQuote);
  });

  test('toJsonString generates valid jsonString', () {
    final sampleQuote = Quote(
      id: Id(10.toNatural()),
      content: NonBlankString(faker.lorem.sentences(3).join(' ')),
      author: NonBlankString(faker.person.name()),
      createdAt: faker.date.dateTime(maxYear: 2024),
      updatedAt: faker.date.dateTime(minYear: 2025),
      tags: {
        Tag(id: Id(5.toNatural()), label: NonBlankString(faker.lorem.word())),
      },
    );

    final sampleQuoteJsonString = sampleQuote.toJsonString();

    final result = Quote.fromJsonString(sampleQuoteJsonString);

    expect(result.asOk.value, equals(sampleQuote));
  });
}
