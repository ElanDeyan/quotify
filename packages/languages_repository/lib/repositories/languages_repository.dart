import 'package:quotify_utils/result.dart';

import '../models/language_errors.dart';
import '../models/languages.dart';

/// A repository that provides methods to get the current language.
abstract interface class LanguagesRepository {
  /// This variable is used to store the key that will be used to save and
  /// retrieve the language data in the repository.
  static const languageKey = 'language';

  /// Defines a function for initializing the repository.
  Future<void> initialize();

  /// Gets the current language.
  FutureResult<Languages, LanguageErrors> fetchCurrentLanguage();

  /// Sets the current language.
  FutureResult<(), LanguageErrors> setCurrentLanguage(Languages language);
}
