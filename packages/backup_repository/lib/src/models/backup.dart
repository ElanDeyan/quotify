import 'dart:convert';

import 'package:languages_repository/models/languages.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotify_utils/result.dart';
import 'package:quotify_utils/serialization/interfaces/encodable.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';

import 'backup_model_errors.dart';

/// Represents User preferences and data.
final class Backup implements Encodable {
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

  /// Method to copy.
  Backup copyWith({
    ThemeBrightness? themeBrightness,
    PrimaryColors? primaryColor,
    Languages? language,
    PrivacyData? privacyData,
    Set<Tag>? tags,
    Set<Quote>? quotes,
  }) =>
      Backup(
        themeBrightness: themeBrightness ?? this.themeBrightness,
        primaryColor: primaryColor ?? this.primaryColor,
        language: language ?? this.language,
        privacyData: privacyData ?? this.privacyData,
        tags: tags ?? this.tags,
        quotes: quotes ?? this.quotes,
      );

  @override
  String toJsonString() => jsonEncode(toMap());

  @override
  Map<String, Object?> toMap() => {
        ThemeBrightness.jsonKey: themeBrightness.name,
        PrimaryColors.jsonKey: primaryColor.name,
        Languages.jsonKey: language.languageCode,
        PrivacyData.jsonKey: privacyData.toMap(),
        Tag.listOfTagsJsonKey: [for (final tag in tags) tag.toMap()],
        Quote.listOfQuotesJsonKey: [for (final quote in quotes) quote.toMap()],
      };

  /// Returns a [Result] that can contains a [Backup] if successful or an
  /// [BackupModelErrors] if something went wrong.
  static Result<Backup, BackupModelErrors> fromMap(Map<String, Object?> map) {
    if (map
        case {
          ThemeBrightness.jsonKey: final String themeBrightnessString,
          PrimaryColors.jsonKey: final String primaryColorString,
          Languages.jsonKey: final String languageCode,
          PrivacyData.jsonKey: final Map<String, Object?> privacyDataMap,
          Tag.listOfTagsJsonKey: final List<Object?> listOfTagsMap,
          Quote.listOfQuotesJsonKey: final List<Object?> listOfQuotesMap,
        }) {
      final ThemeBrightness themeBrightness;
      if (ThemeBrightness.fromString(themeBrightnessString)
          case Ok(:final value)) {
        themeBrightness = value;
      } else {
        return const Result.failure(BackupModelErrors.invalidThemeBrightness);
      }

      final PrimaryColors primaryColor;
      if (PrimaryColors.fromString(primaryColorString) case Ok(:final value)) {
        primaryColor = value;
      } else {
        return const Result.failure(BackupModelErrors.invalidPrimaryColor);
      }

      final Languages language;
      if (Languages.fromLanguageCodeString(languageCode)
          case Ok(:final value)) {
        language = value;
      } else {
        return const Result.failure(BackupModelErrors.invalidLanguageCode);
      }

      final PrivacyData privacyData;
      if (PrivacyData.fromMap(privacyDataMap) case Ok(:final value)) {
        privacyData = value;
      } else {
        return const Result.failure(BackupModelErrors.invalidPrivacyDataMap);
      }

      final Set<Tag> tags;
      if (listOfTagsMap case final List<Map<String, Object?>> listOfMap) {
        final results = listOfMap.map(Tag.fromMap);
        if (results.anyFailure()) {
          return const Result.failure(
            BackupModelErrors.atLeastOneInvalidTagMap,
          );
        }

        tags = Set.of(results.allOks.map((e) => e.value));
      } else {
        return const Result.failure(BackupModelErrors.missingListOfMaps);
      }

      final Set<Quote> quotes;
      if (listOfQuotesMap case final List<Map<String, Object?>> listOfMap) {
        final results = listOfMap.map(Quote.fromMap);
        if (results.anyFailure()) {
          return const Result.failure(
            BackupModelErrors.atLeastOneInvalidQuoteMap,
          );
        }

        quotes = Set.of(results.allOks.map((e) => e.value));
      } else {
        return const Result.failure(BackupModelErrors.missingListOfMaps);
      }

      return Result.ok(
        Backup(
          themeBrightness: themeBrightness,
          primaryColor: primaryColor,
          language: language,
          privacyData: privacyData,
          tags: tags,
          quotes: quotes,
        ),
      );
    }

    return const Result.failure(BackupModelErrors.invalidMapRepresentation);
  }

  /// Forwards to [fromMap] when [jsonString] is a json map, or
  /// [BackupModelErrors.invalidJsonString] when isn't it.
  static Result<Backup, BackupModelErrors> fromJsonString(String jsonString) {
    final Object? decodedJsonString;

    try {
      decodedJsonString = jsonDecode(jsonString);
    } on Object catch (_, stackTrace) {
      return Result.failure(
        BackupModelErrors.invalidJsonString,
        stackTrace,
      );
    }

    if (decodedJsonString case final Map<String, Object?> map) {
      return fromMap(map);
    }

    return const Result.failure(BackupModelErrors.invalidJsonString);
  }

  /// Key for using in serialization.
  static const jsonKey = 'backup';
}
