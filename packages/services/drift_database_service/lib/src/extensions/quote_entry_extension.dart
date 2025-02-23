import 'package:drift/drift.dart';
import 'package:quotes_repository/repositories/quote_entry.dart';

import '../database/app_database.dart';

extension QuoteEntryExtension on QuoteEntry {
  QuotesCompanion toQuotesCompanion() => switch (this) {
        PartialQuoteEntry(
          :final content,
          :final author,
          :final source,
          :final sourceUri,
          :final isFavorite,
          :final tags
        ) =>
          QuotesCompanion(
            content: Value(content),
            author: Value(author),
            source: Value(source),
            sourceUri: Value(sourceUri),
            isFavorite: Value(isFavorite),
            tags: Value(tags),
          ),
        FullQuoteEntry(
          :final content,
          :final author,
          :final source,
          :final sourceUri,
          :final isFavorite,
          :final tags,
          :final id,
          :final createdAt,
          :final updatedAt
        ) =>
          QuotesCompanion(
            id: Value(id.toInt()),
            content: Value(content),
            author: Value(author),
            source: Value(source),
            sourceUri: Value(sourceUri),
            isFavorite: Value(isFavorite),
            createdAt: Value(createdAt),
            updatedAt: Value(updatedAt),
            tags: Value(tags),
          ),
      };
}
