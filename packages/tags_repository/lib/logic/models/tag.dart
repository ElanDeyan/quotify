import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/serialization/interfaces/encodable.dart';

import 'tag_errors.dart';

/// A [Tag] to categorize a Quote.
@immutable
final class Tag implements Encodable, Diagnosticable {
  /// A [Tag] to categorize a Quote.
  const Tag({required this.id, required this.label});

  /// A [Id] id for tag identification.
  final Id id;

  /// A label to be displayed and categorize a Quote.
  final NonBlankString label;

  /// Copies [Tag] with specified parameters.
  Tag copyWith({
    Id? id,
    NonBlankString? label,
  }) =>
      Tag(
        id: id ?? this.id,
        label: label ?? this.label,
      );

  @override
  String toJsonString() => jsonEncode(toMap());

  @override
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id.toInt(),
        'label': label,
      };

  @override
  bool operator ==(covariant Tag other) =>
      id == other.id && label == other.label;

  @override
  int get hashCode => id.toInt().hashCode ^ label.hashCode;

  /// Creates a `Tag` object from a given map representation.
  ///
  /// The map must contain the following keys:
  /// - 'id': an integer representing the tag's ID, which must be non-negative.
  /// - 'label': a non-empty string representing the tag's label.
  ///
  /// If the map contains valid data, a `Result.ok` containing the `Tag`
  /// object is returned.
  /// Otherwise, a `Result.failure` with `TagErrors.invalidMapRepresentation`
  /// and the current stack trace is returned.
  ///
  /// Example:
  /// ```dart
  /// final map = {'id': 1, 'label': 'example'};
  /// final result = Tag.fromMap(map);
  /// if (result case final Ok(:value) ) {
  ///   final tag = value;
  ///   // Use the tag object
  /// } else {
  ///   // Handle the error
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - map: A map containing the tag's data.
  /// - Returns: A `Result` containing either a `Tag` object or an error.
  static Result<Tag> fromMap(Map<String, Object?> map) {
    if (map case {'id': final int id, 'label': final String label}
        when !id.isNegative && label.trim().isNotEmpty) {
      return Result.ok(
        Tag(id: Id(id.toNatural()), label: NonBlankString(label)),
      );
    }

    return Result.failure(
      TagErrors.invalidMapRepresentation,
      StackTrace.current,
    );
  }

  /// Converts a JSON string into a `Tag` object.
  ///
  /// This method attempts to decode the provided JSON string and convert it 
  /// into a `Tag` object. If the JSON string is invalid or does not represent
  /// a valid map, it returns a failure result with the appropriate error.
  ///
  /// - Parameters:
  ///   - jsonString: The JSON string to be converted into a `Tag` object.
  ///
  /// - Returns: A `Result<Tag>` object which is either a success containing the
  ///   `Tag` object or a failure containing the error and stack trace.
  static Result<Tag> fromJsonString(String jsonString) {
    late final Object? decodedJson;

    try {
      decodedJson = jsonDecode(jsonString);
    } on FormatException catch (error, stackTrace) {
      return Result.failure(TagErrors.invalidJsonString, stackTrace);
    }

    if (decodedJson case final Map<String, Object?> map) {
      return fromMap(map);
    }

    return Result.failure(
      TagErrors.invalidMapRepresentation,
      StackTrace.current,
    );
  }

  @override
  String toDiagnosticableString() {
    return '''
Class: Tag
HashCode: $hashCode
Modifiers:
  - final
Implements:
  - Encodable
  - Diagnosticable
Members:
  - id: $id
  - label: $label
''';
  }
}
