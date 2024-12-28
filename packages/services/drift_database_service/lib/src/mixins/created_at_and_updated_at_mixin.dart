import 'package:drift/drift.dart';

/// A mixin that adds `createdAt` and `updatedAt` fields to a table.
///
/// This mixin can be used to automatically manage the creation and
/// update timestamps for a table in a Drift database.
///
/// Fields:
/// - `createdAt`: The timestamp when the record was created.
/// Defaults to the [currentDateAndTime].
/// - `updatedAt`: The timestamp when the record was last updated.
/// Defaults to the [currentDateAndTime].
mixin CreatedAtAndUpdatedAtMixin on Table {
  /// Created at [Column].
  late final createdAt = dateTime().withDefault(currentDateAndTime)();

  /// Updated at [Column].
  late final updatedAt = dateTime().withDefault(currentDateAndTime)();
}
