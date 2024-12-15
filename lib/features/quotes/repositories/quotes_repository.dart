import 'package:quotify_utils/quotify_utils.dart';

import '../../core/id.dart';
import '../../tags/logic/models/tag.dart';
import '../logic/models/quote.dart';
import 'quote_entry.dart';

/// Repository Interface for Quotes
abstract interface class QuotesRepository {
  Future<List<Quote>> get allQuotes;

  Future<Quote?> get randomQuote;

  Future<Quote?> getQuoteById(Id quoteId);

  Future<List<Quote>> getQuotesWithTag(Tag tag);

  FutureResult<Quote> createQuote(QuoteEntry quote);

  FutureResult<Quote> updateQuote(QuoteEntry quote);

  FutureResult<Quote> deleteQuote(Id quoteId);

  Future<bool> deleteAllQuotes();

  Future<bool> restoreQuotes(List<Quote> quotes);

  Future<List<Quote>> get favorites;
}
