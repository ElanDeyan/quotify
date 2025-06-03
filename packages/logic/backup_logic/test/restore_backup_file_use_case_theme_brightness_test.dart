import 'package:backup_logic/backup_logic.dart';
import 'package:backup_logic/src/use_cases/restore_backup.dart';
import 'package:checks/checks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quotify_utils/result.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness_errors.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository_errors.dart';

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
    registerFallbackValue(ThemeBrightness.defaultTheme);
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

  group('theme brightness', () {
    test('when DataSourceToUse is local, '
        'ignore that one coming from backup', () async {
      final useCase = RestoreBackup(
        backup: sampleBackup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.local,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.themeBrightnessBackupRestore();

      verifyNever(themeBrightnessRepository.fetchThemeBrightness);
      verifyNever(() => themeBrightnessRepository.saveThemeBrightness(any()));

      check(result).isA<Ok<(), ThemeBrightnessErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and no problems at writing or fetching, '
        'writes if different', () async {
      const currentThemeBrightness = ThemeBrightness.dark;
      when(
        () => themeBrightnessRepository.fetchThemeBrightness(),
      ).thenAnswer((_) async => const Result.ok(currentThemeBrightness));

      final newThemeBrightness = ThemeBrightness.values
          .whereNot((element) => element == currentThemeBrightness)
          .sample(1)
          .single;

      when(
        () => themeBrightnessRepository.saveThemeBrightness(newThemeBrightness),
      ).thenAnswer((_) async => const Result.ok(()));

      final backup = sampleBackup.copyWith(themeBrightness: newThemeBrightness);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.backup,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.themeBrightnessBackupRestore();

      verify(() => themeBrightnessRepository.fetchThemeBrightness()).called(1);
      verify(
        () => themeBrightnessRepository.saveThemeBrightness(newThemeBrightness),
      ).called(1);

      check(result).isA<Ok<(), ThemeBrightnessErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and no problems at writing or fetching, '
        'writes if different (not writes)', () async {
      const currentThemeBrightness = ThemeBrightness.dark;
      when(
        () => themeBrightnessRepository.fetchThemeBrightness(),
      ).thenAnswer((_) async => const Result.ok(currentThemeBrightness));

      const sameThemeBrightness = currentThemeBrightness;

      final backup = sampleBackup.copyWith(
        themeBrightness: sameThemeBrightness,
      );

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.backup,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.themeBrightnessBackupRestore();

      verify(() => themeBrightnessRepository.fetchThemeBrightness()).called(1);
      verifyNever(
        () =>
            themeBrightnessRepository.saveThemeBrightness(sameThemeBrightness),
      );

      check(result).isA<Ok<(), ThemeBrightnessErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and fails at fetching, not writes', () async {
      when(themeBrightnessRepository.fetchThemeBrightness).thenAnswer(
        (_) async =>
            const Result.failure(ThemeBrightnessRepositoryErrors.missing),
      );

      final sampleThemeBrightness = ThemeBrightness.values.sample(1).single;
      final backup = sampleBackup.copyWith(
        themeBrightness: sampleThemeBrightness,
      );

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.backup,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.themeBrightnessBackupRestore();

      check(result).isA<Failure<(), ThemeBrightnessErrors>>();

      verify(themeBrightnessRepository.fetchThemeBrightness).called(1);
      verifyNever(
        () => themeBrightnessRepository.saveThemeBrightness(
          sampleThemeBrightness,
        ),
      );
    });

    test('when DataSourceToUse is backup, '
        'and fails at writing, not writes, keep old', () async {
      final currentThemeBrightness = ThemeBrightness.values.sample(1).single;
      when(
        themeBrightnessRepository.fetchThemeBrightness,
      ).thenAnswer((_) async => Result.ok(currentThemeBrightness));

      final sampleThemeBrightness = ThemeBrightness.values
          .whereNot((e) => e == currentThemeBrightness)
          .sample(1)
          .single;

      when(
        () => themeBrightnessRepository.saveThemeBrightness(
          sampleThemeBrightness,
        ),
      ).thenAnswer(
        (_) async =>
            const Result.failure(ThemeBrightnessRepositoryErrors.failAtSaving),
      );

      final backup = sampleBackup.copyWith(
        themeBrightness: sampleThemeBrightness,
      );

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.backup,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.themeBrightnessBackupRestore();

      check(result).isA<Failure<(), ThemeBrightnessErrors>>();

      verify(themeBrightnessRepository.fetchThemeBrightness).called(1);
      verify(
        () => themeBrightnessRepository.saveThemeBrightness(
          sampleThemeBrightness,
        ),
      ).called(1);
    });
  });
}
