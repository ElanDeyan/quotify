import 'package:backup_logic/backup_logic.dart';
import 'package:backup_logic/src/use_cases/restore_backup.dart';
import 'package:checks/checks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:languages_repository/models/language_errors.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:languages_repository/repositories/languages_repository_errors.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quotify_utils/result.dart';

import 'mocks/repository_mocks.dart';
import 'utils/sample_backup_generator.dart';

void main() {
  late MockQuotesRepository quotesRepository;
  late MockTagRepository tagRepository;
  late MockLanguagesRepository languagesRepository;
  late MockPrimaryColorsRepository primaryColorsRepository;
  late MockPrivacyRepository privacyRepository;
  late MockThemeBrightnessRepository themeBrightnessRepository;
  late Backup sampleBackup;

  setUpAll(() {
    registerFallbackValue(Languages.defaultLanguage);
  });

  setUp(() {
    themeBrightnessRepository = MockThemeBrightnessRepository();
    primaryColorsRepository = MockPrimaryColorsRepository();
    languagesRepository = MockLanguagesRepository();
    privacyRepository = MockPrivacyRepository();
    tagRepository = MockTagRepository();
    quotesRepository = MockQuotesRepository();
    sampleBackup = sampleBackupGenerator();
  });

  group('language', () {
    test('when DataSourceToUse is local, '
        'ignore that one coming from backup', () async {
      final useCase = RestoreBackup(
        backup: sampleBackup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.local,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.languageBackupRestore();

      verifyNever(languagesRepository.fetchCurrentLanguage);
      verifyNever(() => languagesRepository.setCurrentLanguage(any()));

      check(result).isA<Ok<(), LanguageErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and no problems at writing or fetching, '
        'writes if different', () async {
      final currentLanguage = Languages.values.sample(1).single;
      when(
        languagesRepository.fetchCurrentLanguage,
      ).thenAnswer((_) async => Result.ok(currentLanguage));

      final newLanguage = Languages.values
          .whereNot((element) => element == currentLanguage)
          .sample(1)
          .single;

      when(
        () => languagesRepository.setCurrentLanguage(newLanguage),
      ).thenAnswer((_) async => const Result.ok(()));

      final backup = sampleBackup.copyWith(language: newLanguage);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.backup,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.languageBackupRestore();

      verify(languagesRepository.fetchCurrentLanguage).called(1);
      verify(
        () => languagesRepository.setCurrentLanguage(newLanguage),
      ).called(1);

      check(result).isA<Ok<(), LanguageErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and no problems at writing or fetching, '
        'writes if different (not writes)', () async {
      final currentLanguage = Languages.values.sample(1).single;
      when(
        languagesRepository.fetchCurrentLanguage,
      ).thenAnswer((_) async => Result.ok(currentLanguage));

      final sameLanguage = currentLanguage;

      final backup = sampleBackup.copyWith(language: sameLanguage);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.backup,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.languageBackupRestore();

      verify(languagesRepository.fetchCurrentLanguage).called(1);
      verifyNever(() => languagesRepository.setCurrentLanguage(sameLanguage));

      check(result).isA<Ok<(), LanguageErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and fails at fetching, not writes', () async {
      when(languagesRepository.fetchCurrentLanguage).thenAnswer(
        (_) async =>
            const Result.failure(LanguagesRepositoryErrors.missingLanguageCode),
      );

      final sampleLanguage = Languages.values.sample(1).single;
      final backup = sampleBackup.copyWith(language: sampleLanguage);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.backup,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.languageBackupRestore();

      check(result).isA<Failure<(), LanguageErrors>>();

      verify(languagesRepository.fetchCurrentLanguage).called(1);
      verifyNever(() => languagesRepository.setCurrentLanguage(sampleLanguage));
    });

    test('when DataSourceToUse is backup, '
        'and fails at writing, not writes, keep old', () async {
      final currentLanguage = Languages.values.sample(1).single;
      when(
        languagesRepository.fetchCurrentLanguage,
      ).thenAnswer((_) async => Result.ok(currentLanguage));

      final sampleLanguage = Languages.values
          .whereNot((e) => e == currentLanguage)
          .sample(1)
          .single;

      when(
        () => languagesRepository.setCurrentLanguage(sampleLanguage),
      ).thenAnswer(
        (_) async =>
            const Result.failure(LanguagesRepositoryErrors.failAtSaving),
      );

      final backup = sampleBackup.copyWith(language: sampleLanguage);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.backup,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.languageBackupRestore();

      check(result).isA<Failure<(), LanguageErrors>>();

      verify(languagesRepository.fetchCurrentLanguage).called(1);
      verify(
        () => languagesRepository.setCurrentLanguage(sampleLanguage),
      ).called(1);
    });
  });
}
