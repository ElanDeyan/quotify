// ignore_for_file: one_member_abstracts

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

final class FetchBackupData
    implements UseCase<(), FutureResult<Backup, BackupUseCasesErrors>> {
  const FetchBackupData({
    required this.quotesRepository,
    required this.tagRepository,
    required this.languagesRepository,
    required this.primaryColorsRepository,
    required this.privacyRepository,
    required this.themeBrightnessRepository,
  });

  final QuotesRepository quotesRepository;

  final TagRepository tagRepository;

  final LanguagesRepository languagesRepository;

  final PrimaryColorsRepository primaryColorsRepository;

  final PrivacyRepository privacyRepository;

  final ThemeBrightnessRepository themeBrightnessRepository;

  @override
  FutureResult<Backup, BackupUseCasesErrors> call([
    covariant void arguments,
  ]) async {
    final ThemeBrightness themeBrightness;
    if (await themeBrightnessRepository.fetchThemeBrightness() case Ok(
      :final value,
    )) {
      themeBrightness = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingThemeBrightnessRepository,
      );
    }

    final PrimaryColors primaryColor;
    if (await primaryColorsRepository.fetchPrimaryColor() case Ok(
      :final value,
    )) {
      primaryColor = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingPrimaryColorsRepository,
      );
    }

    final Languages language;
    if (await languagesRepository.fetchCurrentLanguage() case Ok(
      :final value,
    )) {
      language = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingLanguagesRepository,
      );
    }

    final PrivacyData privacyData;
    if (await privacyRepository.fetchPrivacyData() case Ok(:final value)) {
      privacyData = value;
    } else {
      return const Result.failure(
        BackupUseCasesErrors.failAtRequestingPrivacyRepository,
      );
    }

    final tags = Set.of(await tagRepository.allTags);

    final quotes = Set.of(await quotesRepository.allQuotes);

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
