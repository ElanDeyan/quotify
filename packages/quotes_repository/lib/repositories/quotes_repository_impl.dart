import 'dart:collection';
import 'dart:math';

import 'package:drift_database_service/drift_database_service.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../logic/models/quote.dart';
import '../logic/models/quote_errors.dart';
import 'quote_entry.dart';
import 'quote_repository_errors.dart';
import 'quotes_repository.dart';

/// Implementation of [QuotesRepository].
final class QuotesRepositoryImpl implements QuotesRepository {
  /// Implementation of [QuotesRepository].
  const QuotesRepositoryImpl({required AppDatabase appDatabase})
    : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

  @override
  Future<UnmodifiableListView<Quote>> get allQuotes async {
    final quotes = await _appDatabase.allQuotes;

    return UnmodifiableListView(
      quotes.map((quoteTable) => quoteTable.toQuoteModel()),
    );
  }

  @override
  FutureResult<Quote, QuoteErrors> createQuote(PartialQuoteEntry entry) =>
      _appDatabase
          .createQuote(entry)
          .then(
            (value) => value.mapSync(
              (value) => value.toQuoteModel(),
              failureMapper: (_) => QuoteRepositoryErrors.cannotCreateQuote,
            ),
          );

  @override
  FutureResult<Unit, QuoteErrors> deleteAllQuotes() =>
      _appDatabase.clearAllQuotes().then(
        (value) => value.mapSync(
          (value) => value,
          failureMapper: (_) => QuoteRepositoryErrors.cannotDeleteAllQuotes,
        ),
      );

  @override
  FutureResult<Quote, QuoteErrors> deleteQuote(Id quoteId) => _appDatabase
      .deleteQuote(quoteId)
      .then(
        (value) => value.mapSync(
          (value) => value.toQuoteModel(),
          failureMapper: (_) => QuoteRepositoryErrors.cannotDeleteQuote,
        ),
      );

  @override
  Future<UnmodifiableListView<Quote>> get favorites async {
    final result = await _appDatabase.allQuotes;

    return UnmodifiableListView([
      for (final quoteTable in result)
        if (quoteTable.isFavorite) quoteTable.toQuoteModel(),
    ]);
  }

  @override
  Future<Quote?> getQuoteById(Id quoteId) =>
      _appDatabase.getQuoteById(quoteId).then((value) => value?.toQuoteModel());

  @override
  Future<UnmodifiableListView<Quote>> getQuotesWithTag(Id id) async {
    final quotesWithTag = await _appDatabase.getQuotesWithTagId(id);

    return UnmodifiableListView(quotesWithTag.map((e) => e.toQuoteModel()));
  }

  @override
  Future<Quote?> get randomQuote async {
    final allQuotesInDatabase = await allQuotes;

    if (allQuotesInDatabase.isEmpty) return null;

    final randomIndex = Random.secure().nextInt(allQuotesInDatabase.length);

    return allQuotesInDatabase[randomIndex];
  }

  @override
  FutureResult<Quote, QuoteErrors> updateQuote(FullQuoteEntry entry) =>
      _appDatabase
          .updateQuote(entry)
          .then(
            (value) => value.mapSync(
              (value) => value.toQuoteModel(),
              failureMapper: (_) => QuoteRepositoryErrors.cannotUpdateQuote,
            ),
          );
}
