import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotes_repository/logic/models/quote_errors.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/logic/models/tag_errors.dart';

void main() {
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
          equals(TagErrors.invalidMapRepresentation),
        );
      });
    });
  });
}
