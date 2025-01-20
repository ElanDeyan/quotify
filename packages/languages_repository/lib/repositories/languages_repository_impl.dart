import 'package:logging/logging.dart';
import 'package:quotify_utils/result.dart';
import 'package:shared_preferences_service/shared_preferences_async_service.dart';

import '../models/language_errors.dart';
import '../models/languages.dart';
import 'languages_repository.dart';
import 'languages_repository_errors.dart';

/// A repository that provides methods to get the current language.
final class LanguagesRepositoryImpl implements LanguagesRepository {
  /// Initializes a new instance of the [LanguagesRepositoryImpl] class.
  LanguagesRepositoryImpl(this._sharedPreferencesAsyncService);

  final SharedPreferencesAsyncService _sharedPreferencesAsyncService;

  final _log = Logger('LanguagesRepositoryImpl');

  @override
  Future<void> initialize() => _setDefaultIfMissing();

  Future<void> _setDefaultIfMissing() async {
    if (await _sharedPreferencesAsyncService
        .containsKey(LanguagesRepository.languageKey)) {
      return;
    }

    await setCurrentLanguage(Languages.defaultLanguage);
  }

  @override
  FutureResult<Languages, LanguageErrors> fetchCurrentLanguage() async {
    if (!(await _sharedPreferencesAsyncService
        .containsKey(LanguagesRepository.languageKey))) {
      _log.warning(
        'Missing language code value',
        LanguagesRepositoryErrors.missingLanguageCode,
        StackTrace.current,
      );
      return Result.failure(
        LanguagesRepositoryErrors.missingLanguageCode,
        StackTrace.current,
      );
    }

    final storedValue = await _sharedPreferencesAsyncService
        .getString(LanguagesRepository.languageKey);

    return Languages.fromLanguageCodeString(storedValue ?? '');
  }

  @override
  FutureResult<(), LanguageErrors> setCurrentLanguage(
    Languages language,
  ) async {
    try {
      await _sharedPreferencesAsyncService.setString(
        LanguagesRepository.languageKey,
        language.languageCode,
      );

      return const Result.ok(());
    } on Object catch (error, stackTrace) {
      _log.warning('Fail at saving $language', error, stackTrace);
      return Result.failure(LanguagesRepositoryErrors.failAtSaving, stackTrace);
    }
  }
}
