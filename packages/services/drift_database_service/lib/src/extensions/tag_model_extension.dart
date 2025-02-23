import 'package:drift/drift.dart';
import 'package:tags_repository/logic/models/tag.dart';

import '../database/app_database.dart';

/// Extension on the `Tag` class to provide additional functionality.
extension TagModelExtension on Tag {
  /// Converts a `Tag` instance to a `TagsCompanion` instance.
  ///
  /// This method maps the `id` and `label` properties of the `Tag` instance
  /// to the corresponding fields in the `TagsCompanion` instance.
  ///
  /// Returns:
  ///   A `TagsCompanion` instance with the `id` and `label` values
  /// from the `Tag` instance.
  TagsCompanion toTagsCompanion() => TagsCompanion(
        id: Value(id.toInt()),
        label: Value(label),
      );
}
