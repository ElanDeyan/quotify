import 'package:quotify_utils/result.dart';

import '../logic/models/theme_brightness.dart';
import '../logic/models/theme_brightness_errors.dart';
import 'theme_brightness_repository_errors.dart';

/// Defines methods for fetching and saving [ThemeBrightness]
/// settings asynchronously.
abstract interface class ThemeBrightnessRepository {
  /// Provides a standardized way to refer to this specific setting key
  /// throughout the repository implementation and any other related code.
  static const themeBrightnessRepositoryKey = 'themeBrightness';

  /// Defines a function for initializing the repository.
  Future<void> initialize();

  /// Fetches the theme brightness settings asynchronously.
  ///
  /// It returns a [FutureResult] object that will eventually
  /// contain a [ThemeBrightness] on [Ok]. Can return a [Failure] with some
  /// [ThemeBrightnessErrors].
  FutureResult<ThemeBrightness, ThemeBrightnessErrors> fetchThemeBrightness();

  /// Defines a function for saving the [ThemeBrightness] settings
  /// asynchronously.
  FutureResult<(), ThemeBrightnessRepositoryErrors> saveThemeBrightness(
    ThemeBrightness themeBrightness,
  );
}
