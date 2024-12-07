import 'package:logging/logging.dart';

import '../../../utils/future_result.dart';
import '../../../utils/result.dart';
import '../../core/services/notifier.dart';
import '../../core/services/shared_preferences_async_service.dart';
import '../logic/models/primary_colors.dart';
import 'primary_colors_repository.dart';
import 'primary_colors_repository_errors.dart';

/// Concrete implementation of [PrimaryColorsRepository].
final class PrimaryColorsRepositoryImpl implements PrimaryColorsRepository {
  /// Uses a [SharedPreferencesAsyncService] to store this data.
  ///
  /// You must call [initialize] to ensure that you will have a default value
  /// if missing.
  PrimaryColorsRepositoryImpl(
    this.sharedPreferencesAsyncService, {
    required this.notifier,
  });

  final _log = Logger('PrimaryColorsRepositoryImpl');

  /// Stores an instance of the [SharedPreferencesAsyncService] class,
  /// which is a service used to interact with shared preferences package.
  final SharedPreferencesAsyncService sharedPreferencesAsyncService;

  /// Class used for notifying listeners or handling notifications within
  /// the application.
  final Notifier notifier;

  /// Loads default values if they are missing asynchronously.
  Future<void> initialize() => _setDefaultIfMissing();

  Future<void> _setDefaultIfMissing() async {
    if (await sharedPreferencesAsyncService
        .containsKey(PrimaryColorsRepository.primaryColorKey)) {
      return;
    }

    await savePrimaryColor(PrimaryColors.defaultColor);
  }

  @override
  FutureResult<PrimaryColors> fetchPrimaryColor() async {
    try {
      final storedValue = await sharedPreferencesAsyncService
          .getString(PrimaryColorsRepository.primaryColorKey);
      if (storedValue != null) {
        return PrimaryColors.fromString(storedValue);
      } else {
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
    } catch (error, stackTrace) {
      return Result.failure(
        PrimaryColorsRepositoryErrors.unknown,
        stackTrace,
      );
    }
  }

  @override
  FutureResult<void> savePrimaryColor(PrimaryColors primaryColor) async {
    try {
      await sharedPreferencesAsyncService.setString(
        PrimaryColorsRepository.primaryColorKey,
        primaryColor.name,
      );
      return const Result.ok(null);
    } catch (error, stackTrace) {
      _log.warning(
        'Failed in save $primaryColor',
        error,
        stackTrace,
      );
      return Result<void>.failure(
        PrimaryColorsRepositoryErrors.failAtSaving,
        stackTrace,
      );
    } finally {
      notifier.notifyListeners();
    }
  }
}
