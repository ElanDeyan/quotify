import 'package:quotify_utils/quotify_utils.dart';

/// A class representing a tag entry with a non-blank label.
final class TagEntry {
  /// Creates a [TagEntry] with the given non-blank label.
  ///
  /// The [label] parameter must not be null and must be a non-blank string.
  const TagEntry({required this.label});

  /// The non-blank label of the tag entry.
  final NonBlankString label;
}
