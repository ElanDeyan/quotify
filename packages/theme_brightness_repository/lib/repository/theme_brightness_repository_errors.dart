import '../logic/models/theme_brightness_errors.dart';
import 'theme_brightness_repository.dart';

/// Represents different error states or conditions related
/// to [ThemeBrightnessRepository].
enum ThemeBrightnessRepositoryErrors implements ThemeBrightnessErrors {
  /// Represents a specific error state or condition
  /// related to the [ThemeBrightnessRepository] when a value is missing.
  missing,

  /// Represents an error that occurs when there is a failure during the process
  /// of saving data in the [ThemeBrightnessRepository].
  failAtSaving,
}
