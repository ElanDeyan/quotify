import 'package:collection/collection.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/logic/models/tag.dart';

import '../logic/models/quote.dart';
import '../logic/models/quote_errors.dart';
import 'quote_entry.dart';

/// An abstract interface class that defines the contract for a Quotes
///  Repository.
/// This repository provides methods to manage and retrieve quotes.
abstract interface class QuotesRepository {
  /// Retrieves all quotes.
  ///
  /// Returns a [Future] that completes with an [UnmodifiableListView] of
  /// [Quote] objects.
  Future<UnmodifiableListView<Quote>> get allQuotes;

  /// Retrieves a random quote.
  ///
  /// Returns a [Future] that completes with a [Quote] object, or `null` if no
  /// quotes are available.
  Future<Quote?> get randomQuote;

  /// Retrieves a quote by its ID.
  ///
  /// [quoteId] - The ID of the quote to retrieve.
  ///
  /// Returns a [Future] that completes with a [Quote] object, or `null` if
  /// no quote with the given ID is found.
  Future<Quote?> getQuoteById(Id quoteId);

  /// Retrieves quotes that are tagged with a specific tag.
  ///
  /// [tag] - The tag to filter quotes by.
  ///
  /// Returns a [Future] that completes with an [UnmodifiableListView] list of
  /// [Quote] objects that  have the specified tag.
  Future<UnmodifiableListView<Quote>> getQuotesWithTag(Tag tag);

  /// Creates a new quote.
  ///
  /// [entry] - The partial quote entry containing the details of the quote
  /// to create.
  ///
  /// Returns a [FutureResult] that completes with the created [Quote] object.
  FutureResult<Quote, QuoteErrors> createQuote(PartialQuoteEntry entry);

  /// Updates an existing quote.
  ///
  /// [entry] - The full quote entry containing the updated details of the
  /// quote.
  ///
  /// Returns a [FutureResult] that completes with the updated [Quote] object.
  FutureResult<Quote, QuoteErrors> updateQuote(FullQuoteEntry entry);

  /// Deletes a quote by its ID.
  ///
  /// [quoteId] - The ID of the quote to delete.
  ///
  /// Returns a [FutureResult] that completes with the deleted [Quote] object.
  FutureResult<Quote, QuoteErrors> deleteQuote(Id quoteId);

  /// Deletes all quotes.
  ///
  /// Returns a [FutureResult] that completes when all quotes have been deleted.
  FutureResult<Unit, QuoteErrors> deleteAllQuotes();

  /// Retrieves all favorite quotes.
  ///
  /// Returns a [Future] that completes with an [UnmodifiableListView] of
  /// favorite [Quote] objects.
  Future<UnmodifiableListView<Quote>> get favorites;
}
