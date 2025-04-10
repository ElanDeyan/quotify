import 'package:drift/drift.dart';
import 'package:drift_database_service/src/database/app_database.dart';
import 'package:quotes_repository/logic/models/quote.dart';

/// Extension on [Quote].
extension QuoteModelExtension on Quote {
  /// Converts [Quote] to [QuotesCompanion].
  QuotesCompanion toQuotesCompanion() => QuotesCompanion(
        id: Value(id.toInt()),
        content: Value(content),
        author: Value(author),
        isFavorite: Value(isFavorite),
        source: Value(source),
        sourceUri: Value(sourceUri),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        tags: Value(tags),
      );
}
