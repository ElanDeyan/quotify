import 'package:languages_repository/models/languages.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:tags_repository/models/tag.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';

import '../../../quotes/logic/models/quote.dart';

/// Represents User preferences and data.
final class Backup {
  /// Represents User preferences and data.
  const Backup({
    required this.themeBrightness,
    required this.primaryColor,
    required this.language,
    required this.privacyData,
    required this.tags,
    required this.quotes,
  });

  /// Preferred [ThemeBrightness].
  final ThemeBrightness themeBrightness;

  /// Preferred [PrimaryColors].
  final PrimaryColors primaryColor;

  /// Preferred [Languages].
  final Languages language;

  /// This property represents the privacy data associated with the user
  /// preferences.
  final PrivacyData privacyData;

  /// All added [Tag]s.
  final Set<Tag> tags;

  /// All added [Quote]s.
  final Set<Quote> quotes;
}
