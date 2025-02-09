import 'package:cross_file/src/types/interface.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/repositories/quotes_repository.dart';
import 'package:quotify_utils/result.dart';
import 'package:quotify_utils/src/unit.dart';
import 'package:tags_repository/repositories/tag_repository.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository.dart';

import '../models/backup.dart';
import '../models/backup_errors.dart';
import '../models/min_8_length_password.dart';
import 'backup_repository.dart';
import 'backup_repository_errors.dart';

final class BackupRepositoryImpl implements BackupRepository {
  const BackupRepositoryImpl({
    required this.languagesRepository,
    required this.primaryColorsRepository,
    required this.privacyRepository,
    required this.quotesRepository,
    required this.tagRepository,
    required this.themeBrightnessRepository,
  });

  @override
  FutureResult<Backup, BackupRepositoryErrors> fetchBackup() async {
    final ThemeBrightness themeBrightness;
    if (await themeBrightnessRepository.fetchThemeBrightness()
        case Ok(:final value)) {
      themeBrightness = value;
    } else {
      return const Result.failure(
        BackupRepositoryErrors.failAtRequestingThemeBrightnessRepository,
      );
    }

    final PrimaryColors primaryColor;
    if (await primaryColorsRepository.fetchPrimaryColor()
        case Ok(:final value)) {
      primaryColor = value;
    } else {
      return const Result.failure(
        BackupRepositoryErrors.failAtRequestingPrimaryColorsRepository,
      );
    }

    final Languages language;
    if (await languagesRepository.fetchCurrentLanguage()
        case Ok(:final value)) {
      language = value;
    } else {
      return const Result.failure(
        BackupRepositoryErrors.failAtRequestingLanguagesRepository,
      );
    }

    final PrivacyData privacyData;
    if (await privacyRepository.fetchPrivacyData() case Ok(:final value)) {
      privacyData = value;
    } else {
      return const Result.failure(
        BackupRepositoryErrors.failAtRequestingPrivacyRepository,
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

  @override
  FutureResult<XFile, BackupErrors> generateBackupFile({
    required Min8LengthPassword password,
  }) {
    // TODO: implement generateBackupFile
    throw UnimplementedError();
  }

  @override
  final LanguagesRepository languagesRepository;

  @override
  FutureResult<Backup, BackupErrors> parseBackupFile(
    XFile file, {
    required Min8LengthPassword password,
  }) {
    // TODO: implement parseBackupFile
    throw UnimplementedError();
  }

  @override
  final PrimaryColorsRepository primaryColorsRepository;

  @override
  final PrivacyRepository privacyRepository;

  @override
  final QuotesRepository quotesRepository;

  @override
  FutureResult<Unit, BackupRepositoryErrors> restoreBackup(Backup backup) {
    // TODO: implement restoreBackup
    throw UnimplementedError();
  }

  @override
  final TagRepository tagRepository;

  @override
  final ThemeBrightnessRepository themeBrightnessRepository;
}
