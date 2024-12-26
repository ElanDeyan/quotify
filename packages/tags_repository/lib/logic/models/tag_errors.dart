/// An enumeration representing possible errors related to tags.
///
/// This enum implements the [Exception] interface, allowing instances of
/// [TagErrors] to be thrown as exceptions.
enum TagErrors implements Exception {
  /// Indicates that the map representation of a tag is invalid.
  invalidMapRepresentation,

  /// Indicates that the JSON string representation of a tag is invalid.
  invalidJsonString,
}
