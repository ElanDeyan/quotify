import 'package:drift_database_service/drift_database_service.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotify_utils/quotify_utils.dart';

extension QuoteModelExtension on QuoteTable {
  Quote toQuoteModel() => Quote(
        id: Id(id.toNatural()),
        content: NonBlankString(content),
        author: NonBlankString(author),
        createdAt: createdAt,
        updatedAt: updatedAt,
        isFavorite: isFavorite,
        source: source,
        sourceUri: sourceUri,
        tags: tags,
      );
}
