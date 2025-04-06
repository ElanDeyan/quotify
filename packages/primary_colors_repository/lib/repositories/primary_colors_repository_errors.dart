import '../models/primary_colors.dart';
import '../models/primary_colors_errors.dart';
import 'primary_colors_repository.dart';

/// This enum can be used to represent different types of errors that may occur
/// in a [PrimaryColorsRepository], such as a missing primary color,
/// a failure at saving a primary color, or an unknown error.
/// By implementing the [Exception] class, instances of this enum can be thrown
///  as exceptions in Dart code to handle error scenarios.
enum PrimaryColorsRepositoryErrors implements PrimaryColorsErrors {
  /// Represents an error scenario where a [PrimaryColors] is missing in
  /// the repository. This can be used to indicate situations where a
  /// requested [PrimaryColors] is not found or available in the repository.
  missing,

  /// Represents an error scenario where there is a failure at saving a
  /// [PrimaryColors] in the [PrimaryColorsRepository].
  failAtSaving,

  /// This can be used as a catch-all for any unexpected errors that do not
  ///  fall under the specific categories.
  unknown,
}
