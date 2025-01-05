import 'package:drift_database_service/drift_database_service.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/tag.dart';

/// Extension on `TagTable` to provide additional functionality.
extension TagTableExtension on TagTable {
  /// Converts a `TagTable` instance to a `Tag` instance.
  ///
  /// Returns a `Tag` object with the `id` and `label` properties
  /// initialized from the `TagTable` instance.
  Tag toTag() => Tag(id: Id(Natural(id)), label: NonBlankString(label));
}
