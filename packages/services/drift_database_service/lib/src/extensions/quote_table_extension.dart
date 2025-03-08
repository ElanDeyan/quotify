import 'package:collection/collection.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../database/app_database.dart';

/// Extension for [QuoteTable].
extension QuoteTableExtension on QuoteTable {
  /// Converts a [QuoteTable] to a [Quote].
  Quote toQuoteModel() => Quote(
        id: Id(id.toNatural()),
        content: NonBlankString(content),
        author: NonBlankString(author),
        createdAt: createdAt,
        updatedAt: updatedAt,
        isFavorite: isFavorite,
        source: source,
        sourceUri: sourceUri,
        tags: UnmodifiableSetView(tags),
      );
}
