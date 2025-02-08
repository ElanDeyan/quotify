import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/logic/models/tag_model_errors.dart';

void main() {
  group('fromMap', () {
    group('with valid json', () {
      group('and Natural id and non-blank label', () {
        final sampleTag = Tag(
          id: Id(faker.randomGenerator.integer(50).toNatural()),
          label: NonBlankString(faker.lorem.word()),
        );
        final sampleTagJson = sampleTag.toMap();
        test('should return a Tag', () {
          final result = Tag.fromMap(sampleTagJson);
          expect(result, isA<Ok<Tag, TagModelErrors>>());
          expect(result.asOk.value, equals(sampleTag));
        });
      });

      group('but invalid values', () {
        final tagJsonNegativeId = <String, Object?>{
          'id': -1,
          'label': faker.lorem.word(),
        };

        final tagJsonBlankLabel = <String, Object?>{
          'id': 10,
          'label': '',
        };

        final tagJsonBothInvalid = <String, Object?>{
          'id': -20,
          'label': '',
        };

        test('should return a Failure with invalid map representation', () {
          for (final sample in [
            tagJsonNegativeId,
            tagJsonBlankLabel,
            tagJsonBothInvalid,
          ]) {
            final result = Tag.fromMap(sample);
            expect(result, isA<Failure<Tag, TagModelErrors>>());
            expect(
              result.asFailure.failure,
              equals(TagModelErrors.invalidMapRepresentation),
            );
          }
        });
      });
    });
  });

  group('fromJsonString', () {
    group('with valid json string', () {
      final sampleTag = Tag(
        id: Id(faker.randomGenerator.integer(50).toNatural()),
        label: NonBlankString(faker.lorem.word()),
      );
      final sampleTagJsonString = sampleTag.toJsonString();

      test('should return a Tag', () {
        final result = Tag.fromJsonString(sampleTagJsonString);
        expect(result, isA<Ok<Tag, TagModelErrors>>());
        expect(result.asOk.value, equals(sampleTag));
      });
    });

    group('with invalid json string', () {
      const invalidJsonString = '{invalid json}';

      test('should return a Failure with invalid json string error', () {
        final result = Tag.fromJsonString(invalidJsonString);
        expect(result, isA<Failure<Tag, TagModelErrors>>());
        expect(
          result.asFailure.failure,
          equals(TagModelErrors.invalidJsonString),
        );
      });
    });

    group('with valid json string but invalid map representation', () {
      final invalidTagJsonString = jsonEncode({
        'id': -1,
        'label': '',
      });

      test('should return a Failure with invalid map representation', () {
        final result = Tag.fromJsonString(invalidTagJsonString);
        expect(result, isA<Failure<Tag, TagModelErrors>>());
        expect(
          result.asFailure.failure,
          equals(TagModelErrors.invalidMapRepresentation),
        );
      });
    });

    group('with valid json string but not a map', () {
      final invalidTagJsonString = jsonEncode([
        {
          'id': -1,
          'label': '',
        }
      ]);

      test('should return a Failure with invalid map representation', () {
        final result = Tag.fromJsonString(invalidTagJsonString);
        expect(result, isA<Failure<Tag, TagModelErrors>>());
        expect(
          result.asFailure.failure,
          equals(TagModelErrors.invalidMapRepresentation),
        );
      });
    });
  });
}
