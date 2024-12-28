import 'package:drift/drift.dart';

/// Mixin to add id column to [Table]s.
mixin IntIdPrimaryKeyMixin on Table {
  /// An int, auto-incrementable primary key column.
  late final Column<int> id =
      integer().check(id.isBiggerOrEqualValue(0)).autoIncrement()();
}
