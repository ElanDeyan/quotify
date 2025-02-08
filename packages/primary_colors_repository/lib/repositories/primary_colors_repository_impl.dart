import 'package:logging/logging.dart';
import 'package:quotify_utils/result.dart';
import 'package:shared_preferences_service/shared_preferences_async_service.dart';

import '../models/primary_colors.dart';
import '../models/primary_colors_errors.dart';
import 'primary_colors_repository.dart';
import 'primary_colors_repository_errors.dart';

/// Concrete implementation of [PrimaryColorsRepository].
final class PrimaryColorsRepositoryImpl implements PrimaryColorsRepository {
  /// Uses a [SharedPreferencesAsyncService] to store this data.
  ///
  /// You must call [initialize] to ensure that you will have a default value
  /// if missing.
  PrimaryColorsRepositoryImpl(
    this._sharedPreferencesAsyncService,
  );

  final _log = Logger('PrimaryColorsRepositoryImpl');

  /// Stores an instance of the [SharedPreferencesAsyncService] class,
  /// which is a service used to interact with shared preferences package.
  final SharedPreferencesAsyncService _sharedPreferencesAsyncService;

  /// Set a default value if is missing asynchronously.
  @override
  Future<void> initialize() => _setDefaultIfMissing();

  Future<void> _setDefaultIfMissing() async {
    if (await _sharedPreferencesAsyncService
        .containsKey(PrimaryColorsRepository.primaryColorKey)) {
      return;
    }

    await savePrimaryColor(PrimaryColors.defaultColor);
  }

  @override
  FutureResult<PrimaryColors, PrimaryColorsErrors> fetchPrimaryColor() async {
    if (!(await _sharedPreferencesAsyncService
        .containsKey(PrimaryColorsRepository.primaryColorKey))) {
      _log.warning(
        'Missing primary color key',
        PrimaryColorsRepositoryErrors.missing,
        StackTrace.current,
      );
      return Result.failure(
        PrimaryColorsRepositoryErrors.missing,
        StackTrace.current,
      );
    }
    final storedValue = await _sharedPreferencesAsyncService
        .getString(PrimaryColorsRepository.primaryColorKey);

    return PrimaryColors.fromString(storedValue ?? '');
  }

  @override
  FutureResult<(), PrimaryColorsRepositoryErrors> savePrimaryColor(
    PrimaryColors primaryColor,
  ) async {
    try {
      await _sharedPreferencesAsyncService.setString(
        PrimaryColorsRepository.primaryColorKey,
        primaryColor.name,
      );

      return const Result.ok(());
    } on Object catch (error, stackTrace) {
      _log.warning(
        'Failed in save $primaryColor',
        error,
        stackTrace,
      );

      return Result.failure(
        PrimaryColorsRepositoryErrors.failAtSaving,
        stackTrace,
      );
    }
  }
}
