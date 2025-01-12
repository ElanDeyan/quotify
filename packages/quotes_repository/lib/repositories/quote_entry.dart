import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';

import '../logic/models/quote.dart';
import 'quotes_repository.dart';

/// Sealed class related with [Quote]s, for being added in [QuotesRepository].
sealed class QuoteEntry {
  const QuoteEntry({
    required this.content,
    required this.author,
    required this.source,
    required this.sourceUri,
    required this.isFavorite,
    required this.tags,
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

/// A partial entry for [Quote] class.
///
/// With partial, that means without an Id.
final class PartialQuoteEntry extends QuoteEntry {
  /// A partial entry for [Quote] class.
  ///
  /// With partial, that means without an Id.
  const PartialQuoteEntry({
    required super.content,
    required super.author,
    required super.source,
    required super.sourceUri,
    required super.isFavorite,
    required super.tags,
  });
}

/// A class representing a full quote entry, extending the base [QuoteEntry]
/// class.
///
/// This class includes additional information such as a unique identifier [id].
final class FullQuoteEntry extends QuoteEntry {
  /// Creates a new instance of [FullQuoteEntry].
  ///
  /// All parameters from the base [QuoteEntry] class are required, along with
  /// an additional required parameter [id].
  ///
  /// - [content]: The content of the quote.
  /// - [author]: The author of the quote.
  /// - [source]: The source of the quote.
  /// - [sourceUri]: The URI of the source.
  /// - [isFavorite]: A boolean indicating if the quote is marked as favorite.
  /// - [tags]: A list of tags associated with the quote.
  /// - [id]: The unique identifier for this quote entry.
  const FullQuoteEntry({
    required super.content,
    required super.author,
    required super.source,
    required super.sourceUri,
    required super.isFavorite,
    required super.tags,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The unique identifier for this quote entry.
  final Id id;

  /// [DateTime] creation of the quote.
  final DateTime createdAt;

  /// Last updated [DateTime]. By default it is equal to [createdAt]
  /// when creating.
  final DateTime updatedAt;
}
