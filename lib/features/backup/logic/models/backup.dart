import 'package:languages_repository/models/languages.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';

import '../../../quotes/logic/models/quote.dart';
import '../../../tags/logic/models/tag.dart';

/// Represents User preferences and data.
final class Backup {
  /// Represents User preferences and data.
  const Backup({
    required this.themeBrightness,
    required this.primaryColor,
    required this.language,
    required this.tags,
    required this.quotes,
  });

  /// Preferred [ThemeBrightness].
  final ThemeBrightness themeBrightness;

  /// Preferred [PrimaryColors].
  final PrimaryColors primaryColor;

  /// Preferred [Languages].
  final Languages language;

  /// All added [Tag]s.
  final Set<Tag> tags;

  /// All added [Quote]s.
  final Set<Quote> quotes;
}
