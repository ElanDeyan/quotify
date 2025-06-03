import 'package:backup_logic/backup_logic.dart';
import 'package:backup_logic/src/use_cases/restore_backup.dart';
import 'package:checks/checks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:primary_colors_repository/models/primary_colors_errors.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository_errors.dart';
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
    registerFallbackValue(PrimaryColors.defaultColor);
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

  group('primary color', () {
    test('when DataSourceToUse is local, '
        'ignore that one coming from backup', () async {
      final useCase = RestoreBackup(
        backup: sampleBackup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.local,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.primaryColorBackupRestore();

      verifyNever(primaryColorsRepository.fetchPrimaryColor);
      verifyNever(() => primaryColorsRepository.savePrimaryColor(any()));

      check(result).isA<Ok<(), PrimaryColorsErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and no problems at writing or fetching, '
        'writes if different', () async {
      const currentPrimaryColor = PrimaryColors.softApricot;
      when(
        primaryColorsRepository.fetchPrimaryColor,
      ).thenAnswer((_) async => const Result.ok(currentPrimaryColor));

      final newPrimaryColor = PrimaryColors.values
          .whereNot((element) => element == currentPrimaryColor)
          .sample(1)
          .single;

      when(
        () => primaryColorsRepository.savePrimaryColor(newPrimaryColor),
      ).thenAnswer((_) async => const Result.ok(()));

      final backup = sampleBackup.copyWith(primaryColor: newPrimaryColor);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.backup,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.primaryColorBackupRestore();

      verify(primaryColorsRepository.fetchPrimaryColor).called(1);
      verify(
        () => primaryColorsRepository.savePrimaryColor(newPrimaryColor),
      ).called(1);

      check(result).isA<Ok<(), PrimaryColorsErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and no problems at writing or fetching, '
        'writes if different (not writes)', () async {
      const currentPrimaryColor = PrimaryColors.icyLilac;
      when(
        primaryColorsRepository.fetchPrimaryColor,
      ).thenAnswer((_) async => const Result.ok(currentPrimaryColor));

      const samePrimaryColor = currentPrimaryColor;

      final backup = sampleBackup.copyWith(primaryColor: samePrimaryColor);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.backup,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.primaryColorBackupRestore();

      verify(primaryColorsRepository.fetchPrimaryColor).called(1);
      verifyNever(
        () => primaryColorsRepository.savePrimaryColor(samePrimaryColor),
      );

      check(result).isA<Ok<(), PrimaryColorsErrors>>();
    });

    test('when DataSourceToUse is backup, '
        'and fails at fetching, not writes', () async {
      when(primaryColorsRepository.fetchPrimaryColor).thenAnswer(
        (_) async =>
            const Result.failure(PrimaryColorsRepositoryErrors.missing),
      );

      final samplePrimaryColor = PrimaryColors.values.sample(1).single;
      final backup = sampleBackup.copyWith(primaryColor: samplePrimaryColor);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.backup,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.primaryColorBackupRestore();

      check(result).isA<Failure<(), PrimaryColorsErrors>>();

      verify(primaryColorsRepository.fetchPrimaryColor).called(1);
      verifyNever(
        () => primaryColorsRepository.savePrimaryColor(samplePrimaryColor),
      );
    });

    test('when DataSourceToUse is backup, '
        'and fails at writing, not writes, keep old', () async {
      final currentPrimaryColor = PrimaryColors.values.sample(1).single;
      when(
        primaryColorsRepository.fetchPrimaryColor,
      ).thenAnswer((_) async => Result.ok(currentPrimaryColor));

      final samplePrimaryColor = PrimaryColors.values
          .whereNot((e) => e == currentPrimaryColor)
          .sample(1)
          .single;

      when(
        () => primaryColorsRepository.savePrimaryColor(samplePrimaryColor),
      ).thenAnswer(
        (_) async =>
            const Result.failure(PrimaryColorsRepositoryErrors.failAtSaving),
      );

      final backup = sampleBackup.copyWith(primaryColor: samplePrimaryColor);

      final useCase = RestoreBackup(
        backup: backup,
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
        primaryColorsRepository: primaryColorsRepository,
        primaryColorDataSourceToUse: DataSourceToUse.backup,
        privacyRepository: privacyRepository,
        privacyDataDataSourceToUse: DataSourceToUse.values.sample(1).single,
        themeBrightnessRepository: themeBrightnessRepository,
        themeBrightnessDataSourceToUse: DataSourceToUse.values.sample(1).single,
        tagsConflictResolver: ConflictResolver.replaceWithBackupData,
        quotesConflictResolver: ConflictResolver.replaceWithBackupData,
      );

      final result = await useCase.primaryColorBackupRestore();

      check(result).isA<Failure<(), PrimaryColorsErrors>>();

      verify(primaryColorsRepository.fetchPrimaryColor).called(1);
      verify(
        () => primaryColorsRepository.savePrimaryColor(samplePrimaryColor),
      ).called(1);
    });
  });
}
