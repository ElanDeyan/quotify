import 'package:quotify_utils/result.dart';

import '../models/primary_colors.dart';
import '../models/primary_colors_errors.dart';
import 'primary_colors_repository_errors.dart';

/// Defines methods for fetching and saving [PrimaryColors].
abstract interface class PrimaryColorsRepository {
  /// This variable is used to store the key that will be used to save and
  /// retrieve the primary color data in the repository.
  static const String primaryColorKey = 'primaryColor';

  /// Defines a function for initializing the repository.
  Future<void> initialize();

  /// Function for fetching the [PrimaryColors].
  FutureResult<PrimaryColors, PrimaryColorsErrors> fetchPrimaryColor();

  /// Defines a method for saving the [PrimaryColors] data.
  FutureResult<(), PrimaryColorsRepositoryErrors> savePrimaryColor(
    PrimaryColors primaryColor,
  );
}
