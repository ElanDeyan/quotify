import 'theme_brightness.dart';

/// This enum can be used to represent different error cases related to
/// [ThemeBrightness] in a type-safe manner.
/// The implements [Exception] part indicates that instances
/// of this enum can be treated as exceptions in Dart.
enum ThemeBrightnessErrors implements Exception {
  /// Represents an invalid [String] representation related to the
  /// [ThemeBrightness]. This error can be used to handle situations where
  /// a [String] does not match any valid representation.
  invalidStringRepresentation;
}
