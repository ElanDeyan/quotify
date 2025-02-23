import 'package:drift/drift.dart';

import '../mixins/created_at_and_updated_at_mixin.dart';
import '../mixins/int_id_primary_key_mixin.dart';

/// Represents the `tags` table in the database with additional mixins for
/// primary key and timestamp fields.
///
/// This table contains the following columns:
/// - `id`: An integer primary key, provided by `IntIdPrimaryKeyMixin`.
/// - `createdAt`: A timestamp for when the record was created, provided by
/// `CreatedAtAndUpdatedAtMixin`.
/// - `updatedAt`: A timestamp for when the record was last updated, provided
/// by `CreatedAtAndUpdatedAtMixin`.
/// - `label`: A text column that must have a length greater than 0.
///
/// The table is marked as strict, meaning that all columns must be present
/// and valid for an insert or update operation.
@DataClassName('TagTable')
base class Tags extends Table
    with IntIdPrimaryKeyMixin, CreatedAtAndUpdatedAtMixin {
  /// Label column.
  late final Column<String> label =
      text().check(label.length.isBiggerThanValue(0))();

  @override
  bool get isStrict => true;
}
