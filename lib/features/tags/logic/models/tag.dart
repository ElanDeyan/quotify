import '../../../../utils/non_blank_string.dart';
import '../../../core/id.dart';
import '../../../quotes/logic/models/quote.dart';

/// A [Tag] to categorize a [Quote].
final class Tag {
  /// A [Tag] to categorize a [Quote].
  const Tag({required this.id, required this.label});

  /// A [Id] id for tag identification.
  final Id id;

  /// A label to be displayed and categorize a [Quote].
  final NonBlankString label;

  /// Copies [Tag] with specified parameters.
  Tag copyWith({
    Id? id,
    NonBlankString? label,
  }) =>
      Tag(
        id: id ?? this.id,
        label: label ?? this.label,
      );
}
