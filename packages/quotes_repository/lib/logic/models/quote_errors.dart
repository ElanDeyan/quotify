/// An enumeration of possible errors that can occur within the quotes model.
///
/// This enum implements the [Exception] interface, allowing instances of
/// [QuoteErrors] to be thrown as exceptions.
enum QuoteErrors implements Exception {
  /// Indicates that the map representation of a quote is invalid.
  invalidMapRepresentation,

  /// Indicates that the JSON string representation of a quote is invalid.
  invalidJsonString,

  /// Indicates that the updated date of a quote is before its creation date.
  updatedAtDateBeforeCreatedAt,

  /// Indicates that the source URI of a quote is invalid.
  invalidSourceUri,
}
