import 'package:flutter/foundation.dart';

import '../../../utils/future_result.dart';
import '../logic/models/primary_colors.dart';

/// Defines methods for fetching and saving [PrimaryColors], extending
/// [ChangeNotifier].
abstract interface class PrimaryColorsRepository {
  /// This variable is used to store the key that will be used to save and
  /// retrieve the primary color data in the repository.
  static const String primaryColorKey = 'primaryColor';

  /// Defines a function for initializing the repository.
  Future<void> initialize();

  /// Function for fetching the [PrimaryColors].
  FutureResult<PrimaryColors> fetchPrimaryColor();

  /// Defines a method for saving the [PrimaryColors] data.
  FutureResult<void> savePrimaryColor(PrimaryColors primaryColor);
}
