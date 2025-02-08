import 'dart:convert';

import 'package:drift_database_service/src/utils/tags_set_to_string_converter.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';

void main() {
  const converter = TagsSetToStringConverter();
  group('toSql', () {
    final emptySet = <Tag>{};

    final withTags = <Tag>{
      Tag(
        id: Id(faker.randomGenerator.integer(50).toNatural()),
        label: NonBlankString(faker.lorem.word()),
      ),
      Tag(
        id: Id(faker.randomGenerator.integer(50).toNatural()),
        label: NonBlankString(faker.lorem.word()),
      ),
    };
    test('should return JsonEncode the set with tags to map', () {
      final transformedResultEmptySet = [
        for (final tag in emptySet) tag.toMap(),
      ];

      expect(
        converter.toSql(emptySet),
        equals(jsonEncode(transformedResultEmptySet)),
      );

      final transformedResultWithTags = [
        for (final tag in withTags) tag.toMap(),
      ];

      expect(
        converter.toSql(withTags),
        equals(jsonEncode(transformedResultWithTags)),
      );
    });
  });

  group('fromSql', () {
    const emptyString = '';
    const emptyMap = '{}';
    const emptyList = '[]';
    final sampleTag = Tag(
      id: Id(faker.randomGenerator.integer(50).toNatural()),
      label: NonBlankString(faker.lorem.word()),
    );
    final withValidTagMap = jsonEncode([
      sampleTag.toMap(),
    ]);
    final withOneValidAndOneInvalidTagMap = jsonEncode([
      sampleTag.toMap(),
      {
        'uepaa': 'ratinhoo',
      }
    ]);

    test('with non valid list of maps, returns empty set', () {
      expect(converter.fromSql(emptyString), equals(<Tag>{}));
      expect(converter.fromSql(emptyMap), equals(<Tag>{}));
    });

    test('with empty list, returns empty set', () {
      expect(converter.fromSql(emptyList), equals(<Tag>{}));
    });

    test('with list of maps with only valid ones, returns set with the tag',
        () {
      expect(converter.fromSql(withValidTagMap), equals(<Tag>{sampleTag}));
    });

    test(
        'with list of maps with invalid maps, returns set with the valid '
        'and ignores invalid', () {
      expect(
        converter.fromSql(withOneValidAndOneInvalidTagMap),
        equals(<Tag>{sampleTag}),
      );
    });
  });
}
