import 'package:quotify_utils/result.dart';

import 'theme_brightness_model_errors.dart';

/// Represents different brightness themes in an application,
/// allowing you to easily switch between these predefined options in your code.
enum ThemeBrightness {
  /// Represents a dark color scheme or theme that can be used in the
  /// application.
  dark,

  /// Indicates a light color scheme or theme that can be used in the
  /// application.
  light,

  /// Represents a color scheme or theme that follows the system-wide setting.
  /// This means that the application will automatically adapt its color scheme
  /// based on the system-wide setting for light or dark mode.
  system;

  /// A default value.
  static const defaultTheme = ThemeBrightness.system;

  /// Converts a [String] representation of a [ThemeBrightness] into a [Result]
  /// containing the corresponding [ThemeBrightness] value or an error if the
  /// string is invalid.
  ///
  /// Args:
  ///   string ([String]): The `fromString` method takes a [String] parameter
  /// named `string` and returns a `Result` containing a [ThemeBrightness]
  /// value based on the input string.
  static Result<ThemeBrightness, ThemeBrightnessModelErrors> fromString(
    String string,
  ) =>
      switch (string) {
        'light' => const Result.ok(ThemeBrightness.light),
        'dark' => const Result.ok(ThemeBrightness.dark),
        'system' => const Result.ok(ThemeBrightness.system),
        _ => Result.failure(
            ThemeBrightnessModelErrors.invalidStringRepresentation,
            StackTrace.current,
          ),
      };
}
