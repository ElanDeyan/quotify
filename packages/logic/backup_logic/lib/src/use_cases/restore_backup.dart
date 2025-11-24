import 'package:languages_repository/models/language_errors.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:meta/meta.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:primary_colors_repository/models/primary_colors_errors.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository_errors.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/logic/models/privacy_data_errors.dart';
import 'package:privacy_repository/repositories/privacy_data_repository_errors.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/repositories/quotes_repository.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/repositories/tag_repository.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness_errors.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository_errors.dart';

import '../../backup_logic.dart';
import '../models/restore_backup_results.dart';

final class RestoreBackup implements UseCase<Future<RestoreBackupResults>> {
  const RestoreBackup({
    required Backup backup,
    required QuotesRepository quotesRepository,
    required TagRepository tagRepository,
    required LanguagesRepository languagesRepository,
    required PrimaryColorsRepository primaryColorsRepository,
    required PrivacyRepository privacyRepository,
    required ThemeBrightnessRepository themeBrightnessRepository,
    required DataSourceToUse themeBrightnessDataSourceToUse,
    required DataSourceToUse primaryColorDataSourceToUse,
    required DataSourceToUse languageDataSourceToUse,
    required DataSourceToUse privacyDataDataSourceToUse,
    required ConflictResolver tagsConflictResolver,
    required ConflictResolver quotesConflictResolver,
  }) : _backup = backup,
       _quotesRepository = quotesRepository,
       _tagRepository = tagRepository,
       _languagesRepository = languagesRepository,
       _primaryColorsRepository = primaryColorsRepository,
       _privacyRepository = privacyRepository,
       _themeBrightnessRepository = themeBrightnessRepository,
       _themeBrightnessDataSourceToUse = themeBrightnessDataSourceToUse,
       _primaryColorDataSourceToUse = primaryColorDataSourceToUse,
       _languageDataSourceToUse = languageDataSourceToUse,
       _privacyDataDataSourceToUse = privacyDataDataSourceToUse,
       _tagsConflictResolver = tagsConflictResolver,
       _quotesConflictResolver = quotesConflictResolver;

  final Backup _backup;
  final QuotesRepository _quotesRepository;
  final TagRepository _tagRepository;
  final LanguagesRepository _languagesRepository;
  final PrimaryColorsRepository _primaryColorsRepository;
  final PrivacyRepository _privacyRepository;
  final ThemeBrightnessRepository _themeBrightnessRepository;
  final DataSourceToUse _themeBrightnessDataSourceToUse;
  final DataSourceToUse _primaryColorDataSourceToUse;
  final DataSourceToUse _languageDataSourceToUse;
  final DataSourceToUse _privacyDataDataSourceToUse;
  final ConflictResolver _tagsConflictResolver;
  final ConflictResolver _quotesConflictResolver;

  @override
  Future<RestoreBackupResults> call() async {
    final bool successfulThemeBrightnessRestoring;
    final bool successfulPrimaryColorsRestoring;
    final bool successfulLanguagesRestoring;
    final bool successfulPrivacyDataRestoring;
    final bool successfulTagsRestoring;
    final bool successfulQuotesRestoring;

    final (
      themeBrightnessResult,
      primaryColorResult,
      languageResult,
      privacyDataResult,
    ) = await (
      themeBrightnessBackupRestore(),
      primaryColorBackupRestore(),
      languageBackupRestore(),
      privacyDataRestore(),
    ).wait;

    successfulThemeBrightnessRestoring = themeBrightnessResult.isOk;
    successfulPrimaryColorsRestoring = primaryColorResult.isOk;
    successfulLanguagesRestoring = languageResult.isOk;
    successfulPrivacyDataRestoring = privacyDataResult.isOk;

    return (
      successfulLanguagesRestoring: successfulLanguagesRestoring,
      successfulPrimaryColorsRestoring: successfulPrimaryColorsRestoring,
      successfulPrivacyDataRestoring: successfulPrivacyDataRestoring,
      successfulQuotesRestoring: false,
      successfulTagsRestoring: false,
      successfulThemeBrightnessRestoring: successfulThemeBrightnessRestoring,
    );
  }

  @visibleForTesting
  FutureResult<Unit, ThemeBrightnessErrors>
  themeBrightnessBackupRestore() async {
    switch (_themeBrightnessDataSourceToUse) {
      case DataSourceToUse.local:
        return const Result.ok(());
      case DataSourceToUse.backup:
        final currentThemeBrightnessResult = await _themeBrightnessRepository
            .fetchThemeBrightness();
        if (currentThemeBrightnessResult
            case final Failure<ThemeBrightness, ThemeBrightnessErrors>
                failure) {
          return failure.mapSync((_) => ());
        }

        if (_backup.themeBrightness != currentThemeBrightnessResult.unwrap()) {
          final savingResult = await _themeBrightnessRepository
              .saveThemeBrightness(_backup.themeBrightness);

          if (savingResult
              case final Failure<(), ThemeBrightnessRepositoryErrors> failure) {
            return failure.mapSync((_) => ());
          }
        }

        return const Result.ok(());
    }
  }

  @visibleForTesting
  FutureResult<Unit, PrimaryColorsErrors> primaryColorBackupRestore() async {
    switch (_primaryColorDataSourceToUse) {
      case DataSourceToUse.local:
        return const Result.ok(());
      case DataSourceToUse.backup:
        final currentPrimaryColorResult = await _primaryColorsRepository
            .fetchPrimaryColor();
        if (currentPrimaryColorResult
            case final Failure<PrimaryColors, PrimaryColorsErrors> failure) {
          return failure.mapSync((_) => ());
        }

        if (_backup.primaryColor != currentPrimaryColorResult.unwrap()) {
          final savingResult = await _primaryColorsRepository.savePrimaryColor(
            _backup.primaryColor,
          );

          if (savingResult
              case final Failure<(), PrimaryColorsRepositoryErrors> failure) {
            return failure.mapSync((_) => ());
          }
        }

        return const Result.ok(());
    }
  }

  @visibleForTesting
  FutureResult<Unit, LanguageErrors> languageBackupRestore() async {
    switch (_languageDataSourceToUse) {
      case DataSourceToUse.local:
        return const Result.ok(());
      case DataSourceToUse.backup:
        final currentLanguageResult = await _languagesRepository
            .fetchCurrentLanguage();
        if (currentLanguageResult
            case final Failure<Languages, LanguageErrors> failure) {
          return failure.mapSync((_) => ());
        }

        if (_backup.language != currentLanguageResult.unwrap()) {
          final savingResult = await _languagesRepository.setCurrentLanguage(
            _backup.language,
          );

          if (savingResult case final Failure<(), LanguageErrors> failure) {
            return failure.mapSync((_) => ());
          }
        }

        return const Result.ok(());
    }
  }

  @visibleForTesting
  FutureResult<Unit, PrivacyDataErrors> privacyDataRestore() async {
    switch (_privacyDataDataSourceToUse) {
      case DataSourceToUse.local:
        return const Result.ok(());
      case DataSourceToUse.backup:
        final currentPrivacyDataResult = await _privacyRepository
            .fetchPrivacyData();
        if (currentPrivacyDataResult
            case final Failure<PrivacyData, PrivacyRepositoryErrors> failure) {
          return failure.mapSync((_) => ());
        }

        final currentPrivacyData = currentPrivacyDataResult.unwrap();

        if (_backup.privacyData != currentPrivacyData) {
          final writeBackupPrivacyDataResult = await _privacyRepository
              .savePrivacyData(_backup.privacyData.toPrivacyDataEntry());
          if (writeBackupPrivacyDataResult
              case final Failure<(), PrivacyRepositoryErrors> failure) {
            return failure.mapSync((_) => ());
          }
        }

        return const Result.ok(());
    }
  }
}
