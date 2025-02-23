// ignore_for_file: public_member_api_docs

import 'package:quotify_utils/result.dart';

import 'primary_colors_model_errors.dart';

/// Represents various colors.
enum PrimaryColors {
  coolBlush,
  fireEngineRed,
  icyLilac,
  mistyMint,
  oxfordBlue,
  powderBlue,
  softApricot,
  vanilla;

  /// Default color.
  static const PrimaryColors defaultColor = PrimaryColors.oxfordBlue;

  /// Converts a string to its equivalent [PrimaryColors] member.
  /// Returns [PrimaryColorsModelErrors.invalidStringRepresentation] when
  /// fails to convert.
  static Result<PrimaryColors, PrimaryColorsModelErrors> fromString(
    String string,
  ) =>
      switch (string) {
        'coolBlush' => const Result.ok(PrimaryColors.coolBlush),
        'fireEngineRed' => const Result.ok(PrimaryColors.fireEngineRed),
        'icyLilac' => const Result.ok(PrimaryColors.icyLilac),
        'mistyMint' => const Result.ok(PrimaryColors.mistyMint),
        'oxfordBlue' => const Result.ok(PrimaryColors.oxfordBlue),
        'powderBlue' => const Result.ok(PrimaryColors.powderBlue),
        'softApricot' => const Result.ok(PrimaryColors.softApricot),
        'vanilla' => const Result.ok(PrimaryColors.vanilla),
        _ => Result.failure(
            PrimaryColorsModelErrors.invalidStringRepresentation,
            StackTrace.current,
          ),
      };

  /// Key to be used in serialization
  static const jsonKey = 'primaryColor';
}
