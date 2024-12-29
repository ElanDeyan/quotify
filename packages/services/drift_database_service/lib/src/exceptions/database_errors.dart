/// An enumeration representing possible database errors.
///
/// This enum implements the [Exception] interface, allowing instances of
/// [DatabaseErrors] to be thrown and caught as exceptions.
///
/// Possible values:
/// - [DatabaseErrors.cannotCreateEntry]: Indicates that the entry could not
/// be created. Like a Tag
enum DatabaseErrors implements Exception {
  /// Indicates that the entry, like a Tag, cannot be created.
  cannotCreateEntry,

  cannotUpdateEntry,

  notFoundId,

  
}
