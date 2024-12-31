/// Enum representing various database errors that can occur in the application.
enum DatabaseErrors implements Exception {
  /// Error indicating that an entry could not be created.
  cannotCreateEntry,

  /// Error indicating that an entry could not be updated.
  cannotUpdateEntry,

  /// Error indicating that an entry with the specified ID was not found.
  notFoundId,

  /// Error indicating that an entry could not be deleted.
  cannotDeleteEntry,

  /// Error indicating that too many rows were affected by an operation.
  tooMuchRowsAffected,

  /// Error indicating that not all tags were deleted as expected.
  notDeletedAllTags,
}
