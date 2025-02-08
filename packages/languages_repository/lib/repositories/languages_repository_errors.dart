import '../models/language_errors.dart';
import 'languages_repository.dart';

/// Errors that can occur when interacting with the [LanguagesRepository].
enum LanguagesRepositoryErrors implements LanguageErrors {
  /// Thrown when the language code is missing.
  missingLanguageCode,

  /// This error type represents a specific error scenario related
  /// to failing at saving data within the `LanguagesRepository`.
  failAtSaving;
}
