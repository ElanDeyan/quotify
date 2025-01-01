import 'package:quotify_utils/quotify_utils.dart';

/// A class representing a tag entry with a non-blank label.
sealed class TagEntry {
  /// Creates a [TagEntry] with the given non-blank label.
  ///
  /// The [label] parameter must not be null and must be a non-blank string.
  const TagEntry({required this.label});

  const factory TagEntry.half({required NonBlankString label}) = HalfTagEntry;

  const factory TagEntry.full({required NonBlankString label, required Id id}) =
      FullTagEntry;

  /// The non-blank label of the tag entry.
  final NonBlankString label;
}

/// A class representing a half tag entry, which is a specific type of
/// [TagEntry].
///
/// This class is immutable and requires a label to be provided upon
/// instantiation.
final class HalfTagEntry extends TagEntry {
  /// Creates a new instance of [HalfTagEntry].
  ///
  /// The [label] parameter is required and must not be null.
  const HalfTagEntry({required super.label});
}

/// A class representing a full tag entry, extending the [TagEntry] class.
///
/// This class includes an additional [id] field to uniquely identify the tag
/// entry.
final class FullTagEntry extends TagEntry {
  /// Creates a new [FullTagEntry] instance.
  ///
  /// The [label] parameter is required and is passed to the superclass
  /// [TagEntry].
  /// The [id] parameter is required and uniquely identifies the tag entry.
  const FullTagEntry({required super.label, required this.id});

  /// The unique identifier for the tag entry.
  final Id id;
}
