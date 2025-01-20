import 'tag_errors.dart';

/// An enumeration representing possible errors related to tags.
///
/// This enum implements the [Exception] interface, allowing instances of
/// [TagModelErrors] to be thrown as exceptions.
enum TagModelErrors implements TagErrors {
  /// Indicates that the map representation of a tag is invalid.
  invalidMapRepresentation,

  /// Indicates that the JSON string representation of a tag is invalid.
  invalidJsonString,
}
