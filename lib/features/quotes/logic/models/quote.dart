import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/models/tag.dart';

/// A Quote class.
final class Quote {
  /// A Quote class.
  const Quote({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    this.source,
    this.sourceUri,
    this.isFavorite = false,
    this.tags = const {},
  });

  /// An [Id].
  final Id id;

  /// The content, the phrase itself.
  final NonBlankString content;

  /// The author of the [Quote].
  final NonBlankString author;

  /// Source of the quote, like a chapter of a book or a movie.
  final String? source;

  /// An accessible [Uri] to be launched.
  final Uri? sourceUri;

  /// If the quote was favorite.
  final bool isFavorite;

  /// [DateTime] creation of the quote.
  final DateTime createdAt;

  /// Last updated [DateTime]. By default it is equal to [createdAt]
  /// when creating.
  final DateTime updatedAt;

  /// [Set] of [Tag]s related to this quote.
  final Set<Tag> tags;

  /// Copies [Quote] with specified parameters.
  Quote copyWith({
    Id? id,
    NonBlankString? content,
    NonBlankString? author,
    String? source,
    Uri? sourceUri,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Set<Tag>? tags,
  }) =>
      Quote(
        id: id ?? this.id,
        content: content ?? this.content,
        author: author ?? this.author,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isFavorite: isFavorite ?? this.isFavorite,
        source: source ?? this.source,
        sourceUri: sourceUri ?? this.sourceUri,
        tags: tags ?? this.tags,
      );
}
