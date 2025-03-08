import 'dart:math';

import 'package:backup_logic/backup_logic.dart';
import 'package:collection/collection.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';

import 'sample_quote_generator.dart';
import 'sample_tag_generator.dart';

Backup sampleBackupGenerator({
  int seed = 50,
  ThemeBrightness? themeBrightness,
  PrimaryColors? primaryColor,
  Languages? language,
  PrivacyData? privacyData,
  Natural tagsQuantity = const Natural(0),
  Natural quotesQuantity = const Natural(0),
}) {
  final tags = {
    for (var i = 0; i < tagsQuantity.toInt(); i++) sampleTagGenerator(),
  };
  final quotes = {
    for (var i = 0; i < quotesQuantity.toInt(); i++)
      sampleQuoteGenerator().copyWith(
        tags: UnmodifiableSetView(
          tags.sample(Random(seed).nextInt(tagsQuantity.toInt())).toSet(),
        ),
      ),
  };

  return Backup(
    themeBrightness:
        themeBrightness ??
        ThemeBrightness.values.sample(1, Random(seed)).single,
    primaryColor:
        primaryColor ?? PrimaryColors.values.sample(1, Random(seed)).single,
    language: language ?? Languages.values.sample(1, Random(seed)).single,
    privacyData: privacyData ?? const PrivacyData.initial(),
    tags: UnmodifiableSetView(tags),
    quotes: UnmodifiableSetView(quotes),
  );
}
