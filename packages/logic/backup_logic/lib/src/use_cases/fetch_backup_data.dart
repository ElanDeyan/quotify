import 'package:collection/collection.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/repositories/quotes_repository.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/repositories/tag_repository.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository.dart';

import '../../backup_logic.dart';

/// Represents to fetch a [Backup] instance from the repositories.
final class FetchBackupData
    implements UseCase<FutureResult<Backup, BackupUseCasesErrors>> {
  /// Creates [FetchBackupData].
  const FetchBackupData({
    required QuotesRepository quotesRepository,
    required TagRepository tagRepository,
    required LanguagesRepository languagesRepository,
    required PrimaryColorsRepository primaryColorsRepository,
    required PrivacyRepository privacyRepository,
    required ThemeBrightnessRepository themeBrightnessRepository,
  }) : _themeBrightnessRepository = themeBrightnessRepository,
       _privacyRepository = privacyRepository,
       _primaryColorsRepository = primaryColorsRepository,
       _languagesRepository = languagesRepository,
       _tagRepository = tagRepository,
       _quotesRepository = quotesRepository;

  final QuotesRepository _quotesRepository;

  final TagRepository _tagRepository;

  final LanguagesRepository _languagesRepository;

  final PrimaryColorsRepository _primaryColorsRepository;

  final PrivacyRepository _privacyRepository;

  final ThemeBrightnessRepository _themeBrightnessRepository;

  @override
  FutureResult<Backup, BackupUseCasesErrors> call() async {
    final ThemeBrightness themeBrightness;
    if (await _themeBrightnessRepository.fetchThemeBrightness() case Ok(
      :final value,
    )) {
      themeBrightness = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingThemeBrightnessRepository,
      );
    }

    final PrimaryColors primaryColor;
    if (await _primaryColorsRepository.fetchPrimaryColor() case Ok(
      :final value,
    )) {
      primaryColor = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingPrimaryColorsRepository,
      );
    }

    final Languages language;
    if (await _languagesRepository.fetchCurrentLanguage() case Ok(
      :final value,
    )) {
      language = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingLanguagesRepository,
      );
    }

    final PrivacyData privacyData;
    if (await _privacyRepository.fetchPrivacyData() case Ok(:final value)) {
      privacyData = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingPrivacyRepository,
      );
    }

    final tags = UnmodifiableSetView((await _tagRepository.allTags).toSet());

    final quotes = UnmodifiableSetView(
      (await _quotesRepository.allQuotes).toSet(),
    );

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
}
