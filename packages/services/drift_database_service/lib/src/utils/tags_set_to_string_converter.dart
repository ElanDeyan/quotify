import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/logic/models/tag.dart';

/// A custom [TypeConverter] that converts a [Set] of [Tag] objects to a
/// [String]
/// and vice versa. This is useful for storing a set of tags in a single string
/// format in a database and retrieving it back as a set of tags.
///
/// Example usage:
/// ```dart
/// final converter = TagsSetToStringConverter();
/// final tags = {'tag1', 'tag2'};
/// final stringRepresentation = converter.toSql(tags); // Converts set to string
/// final setRepresentation = converter.fromSql(stringRepresentation); // Converts string back to set
/// ```
final class TagsSetToStringConverter extends TypeConverter<Set<Tag>, String> {
  /// A custom [TypeConverter] that converts a [Set] of [Tag] objects to a
  /// [String]
  /// and vice versa. This is useful for storing a set of tags in a single
  /// string format in a database and retrieving it back as a set of tags.
  ///
  /// Example usage:
  /// ```dart
  /// final converter = TagsSetToStringConverter();
  /// final tags = {'tag1', 'tag2'};
  /// final stringRepresentation = converter.toSql(tags); // Converts set to string
  /// final setRepresentation = converter.fromSql(stringRepresentation); // Converts string back to set
  /// ```
  const TagsSetToStringConverter();
  @override
  Set<Tag> fromSql(String fromDb) {
    late final Object? decoded;
    
    try {
      decoded = jsonDecode(fromDb);
    } on Object {
      return {};
    }

    if (decoded case final List<Object?> list) {
      if (list.every(
        (element) => element is Map<String, Object?>,
      )) {
        final listOfMaps = list.cast<Map<String, Object?>>();
        return {
          for (final map in listOfMaps)
            if (Tag.fromMap(map) case Ok(:final value)) value,
        };
      }
    }

    return const {};
  }

  @override
  String toSql(Set<Tag> value) {
    final tagsSetAsListOfJsonMap = [for (final tag in value) tag.toMap()];

    return jsonEncode(tagsSetAsListOfJsonMap);
  }
}
