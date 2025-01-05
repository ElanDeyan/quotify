/// Enum representing the configuration options for restoring data in
/// the database.
enum RestoreConfig {
  /// Clear existing data and add new data.
  clearAndAdd,

  /// Update existing data on conflict.
  updateOnConflict,

  /// Discard new data on conflict.
  discardOnConflict,
}
