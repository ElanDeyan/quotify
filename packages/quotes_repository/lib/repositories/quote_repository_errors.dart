import '../logic/models/quote_errors.dart';

/// Enum representing the various errors that can occur in the QuoteRepository.
///
/// Implements the [QuoteErrors] interface.
enum QuoteRepositoryErrors implements QuoteErrors {
  /// Error indicating that a quote could not be created.
  cannotCreateQuote,

  /// Error indicating that a quote could not be updated.
  cannotUpdateQuote,

  /// Error indicating that a quote could not be deleted.
  cannotDeleteQuote,

  /// Error indicating that all quotes could not be deleted.
  cannotDeleteAllQuotes,
}
