import 'package:logging/logging.dart';
import 'package:quotify_utils/result.dart';
import 'package:shared_preferences_service/shared_preferences_async_service.dart';

import '../logic/models/theme_brightness.dart';
import '../logic/models/theme_brightness_errors.dart';
import 'theme_brightness_repository.dart';
import 'theme_brightness_repository_errors.dart';

/// Concrete implementation of [ThemeBrightnessRepository].
final class ThemeBrightnessRepositoryImpl implements ThemeBrightnessRepository {
  /// Uses a [SharedPreferencesAsyncService] to store this data.
  ///
  /// You must call [initialize] to ensure that you will have a default value
  /// if missing.
  ThemeBrightnessRepositoryImpl(
    SharedPreferencesAsyncService sharedPreferencesAsyncService,
  ) : _sharedPreferencesAsyncService = sharedPreferencesAsyncService;

  final SharedPreferencesAsyncService _sharedPreferencesAsyncService;

  final _log = Logger('ThemeBrightnessRepositoryImpl');

  /// Set a default value if is missing asynchronously.
  @override
  Future<void> initialize() => _setDefaultIfMissing();

  Future<void> _setDefaultIfMissing() async {
    if (await _sharedPreferencesAsyncService
        .containsKey(ThemeBrightnessRepository.themeBrightnessRepositoryKey)) {
      return;
    }

    await saveThemeBrightness(ThemeBrightness.defaultTheme);
  }

  @override
  FutureResult<ThemeBrightness, ThemeBrightnessErrors>
      fetchThemeBrightness() async {
    if (!(await _sharedPreferencesAsyncService
        .containsKey(ThemeBrightnessRepository.themeBrightnessRepositoryKey))) {
      return Result.failure(
        ThemeBrightnessRepositoryErrors.missing,
        StackTrace.current,
      );
    }

    final storedValue = await _sharedPreferencesAsyncService
        .getString(ThemeBrightnessRepository.themeBrightnessRepositoryKey);

    return ThemeBrightness.fromString(storedValue ?? '');
  }

  @override
  FutureResult<(), ThemeBrightnessRepositoryErrors> saveThemeBrightness(
    ThemeBrightness themeBrightness,
  ) async {
    try {
      await _sharedPreferencesAsyncService.setString(
        ThemeBrightnessRepository.themeBrightnessRepositoryKey,
        themeBrightness.name,
      );

      return const Result.ok(());
    } on Object catch (error, stackTrace) {
      _log.warning('Something went wrong!', error, stackTrace);
      return Result.failure(
        ThemeBrightnessRepositoryErrors.failAtSaving,
        stackTrace,
      );
    }
  }
}
