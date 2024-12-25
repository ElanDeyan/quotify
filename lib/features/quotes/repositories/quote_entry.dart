
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/models/tag.dart';

import '../logic/models/quote.dart';

/// An entry for [Quote] class.
final class QuoteEntry {
  /// An entry for [Quote] class.
  const QuoteEntry({
    required this.content,
    required this.author,
    this.source,
    this.sourceUri,
    this.isFavorite = false,
    this.tags = const {},
  });

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

  /// [Set] of [Tag]s related to this quote.
  final Set<Tag> tags;
}
