import 'primary_colors.dart';
import 'primary_colors_errors.dart';

/// This enum can be used to represent different types of errors related to
/// [PrimaryColors] in a type-safe manner.
enum PrimaryColorsModelErrors implements PrimaryColorsErrors {
  /// Indicates an error where an invalid string representation is encountered
  /// when trying to convert [PrimaryColors] from strings.
  invalidStringRepresentation;
}
