import 'package:drift/drift.dart';
import 'package:tags_repository/repositories/tag_entry.dart';

import '../database/app_database.dart';

/// Extension on `TagEntry` to convert it to a `TagsCompanion`.
extension TagEntryExtension on TagEntry {
  /// Converts a `TagEntry` to a `TagsCompanion`.
  ///
  /// Depending on the type of `TagEntry`, it will create a `TagsCompanion`
  /// with the appropriate fields.
  ///
  /// - For `HalfTagEntry`, it will create a `TagsCompanion` with only the
  /// `label` field.
  /// - For `FullTagEntry`, it will create a `TagsCompanion` with both `id` and
  /// `label` fields.
  TagsCompanion toTagsCompanion() => switch (this) {
        HalfTagEntry(:final label) => TagsCompanion(label: Value(label)),
        FullTagEntry(:final label, :final id) =>
          TagsCompanion(id: Value(id.toInt()), label: Value(label)),
      };
}
