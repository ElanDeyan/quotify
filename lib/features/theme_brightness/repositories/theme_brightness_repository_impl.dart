import 'package:logging/logging.dart';

import '../../../utils/future_result.dart';
import '../../../utils/result.dart';
import '../../core/services/notifier.dart';
import '../../core/services/shared_preferences_async_service.dart';
import '../logic/models/theme_brightness.dart';
import 'theme_brightness_repository.dart';
import 'theme_brightness_repository_errors.dart';

final class ThemeBrightnessRepositoryImpl implements ThemeBrightnessRepository {
  ThemeBrightnessRepositoryImpl({
    required SharedPreferencesAsyncService sharedPreferencesAsyncService,
    required Notifier notifier,
  })  : _sharedPreferencesAsyncService = sharedPreferencesAsyncService,
        _notifier = notifier;

  final SharedPreferencesAsyncService _sharedPreferencesAsyncService;
  final Notifier _notifier;

  final _log = Logger('ThemeBrightnessRepositoryImpl');

  @override
  FutureResult<ThemeBrightness> fetchThemeBrightness() async {
    if (!(await _sharedPreferencesAsyncService
        .containsKey(ThemeBrightnessRepository.themeBrightnessRepositoryKey))) {
      return const Result.failure(
        ThemeBrightnessRepositoryErrors.missing,
        StackTrace.empty,
      );
    }

    final storedValue = await _sharedPreferencesAsyncService
        .getString(ThemeBrightnessRepository.themeBrightnessRepositoryKey);

    return ThemeBrightness.fromString(storedValue ?? '');
  }

  @override
  FutureResult<void> saveThemeBrightness(
    ThemeBrightness themeBrightness,
  ) async {
    await _sharedPreferencesAsyncService.setString(
      ThemeBrightnessRepository.themeBrightnessRepositoryKey,
      themeBrightness.name,
    );

    return const Result.ok(null);
  }
}
