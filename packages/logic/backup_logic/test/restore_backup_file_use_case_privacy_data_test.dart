import 'dart:developer';

import 'package:backup_logic/src/models/conflict_resolver.dart';
import 'package:backup_logic/src/models/data_source_to_keep.dart';
import 'package:backup_logic/src/use_cases/restore_backup.dart';
import 'package:checks/checks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:mocktail/mocktail.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/logic/models/privacy_data_errors.dart';
import 'package:privacy_repository/repositories/privacy_data_entry.dart';
import 'package:quotify_utils/result.dart';

import '../../../../testing/generators/quotify_generators.dart';
import 'mocks/repository_mocks.dart';

void main() {
  late MockQuotesRepository quotesRepository;
  late MockTagRepository tagRepository;
  late MockLanguagesRepository languagesRepository;
  late MockPrimaryColorsRepository primaryColorsRepository;
  late MockPrivacyRepository privacyRepository;
  late MockThemeBrightnessRepository themeBrightnessRepository;

  setUpAll(() {
    registerFallbackValue(const PrivacyData.initial());
    registerFallbackValue(const PrivacyDataEntry());
  });

  setUp(() {
    themeBrightnessRepository = MockThemeBrightnessRepository();
    primaryColorsRepository = MockPrimaryColorsRepository();
    languagesRepository = MockLanguagesRepository();
    privacyRepository = MockPrivacyRepository();
    tagRepository = MockTagRepository();
    quotesRepository = MockQuotesRepository();
  });

  group('privacy data', () {
    property(
      'when data source to use is local, not writes ',
      () => forAll(quotifyBackupGenerator(), (backup) async {
        final useCase = RestoreBackup(
          backup: backup,
          quotesRepository: quotesRepository,
          tagRepository: tagRepository,
          languagesRepository: languagesRepository,
          primaryColorsRepository: primaryColorsRepository,
          privacyRepository: privacyRepository,
          themeBrightnessRepository: themeBrightnessRepository,
          themeBrightnessDataSourceToUse: DataSourceToUse.values
              .sample(1)
              .single,
          primaryColorDataSourceToUse: DataSourceToUse.values.sample(1).single,
          languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
          privacyDataDataSourceToUse: DataSourceToUse.local,
          tagsConflictResolver: ConflictResolver.replaceWithBackupData,
          quotesConflictResolver: ConflictResolver.replaceWithBackupData,
        );

        final result = await useCase.privacyDataRestore();

        verifyNever(() => privacyRepository.savePrivacyData(any()));

        check(result).isA<Ok<(), PrivacyDataErrors>>();
      }),
    );

    group('when data source to use is backup', () {
      property(
        'and local and backup are equal, not writes',
        () => forAll(quotifyBackupGenerator(), (backup) async {
          when(
            privacyRepository.fetchPrivacyData,
          ).thenAnswer((_) async => Result.ok(backup.privacyData));

          final useCase = RestoreBackup(
            backup: backup,
            quotesRepository: quotesRepository,
            tagRepository: tagRepository,
            languagesRepository: languagesRepository,
            primaryColorsRepository: primaryColorsRepository,
            privacyRepository: privacyRepository,
            themeBrightnessRepository: themeBrightnessRepository,
            themeBrightnessDataSourceToUse: DataSourceToUse.values
                .sample(1)
                .single,
            primaryColorDataSourceToUse: DataSourceToUse.values
                .sample(1)
                .single,
            languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
            privacyDataDataSourceToUse: DataSourceToUse.backup,
            tagsConflictResolver: ConflictResolver.values.sample(1).single,
            quotesConflictResolver: ConflictResolver.values.sample(1).single,
          );

          final result = await useCase.privacyDataRestore();

          check(result).isA<Ok<(), PrivacyDataErrors>>();

          verify(privacyRepository.fetchPrivacyData).called(1);
          verifyNever(
            () => privacyRepository.savePrivacyData(
              backup.privacyData.toPrivacyDataEntry(),
            ),
          );
        }),
      );

      property(
        'and local and backup are different, writes',
        () => forAll(
          shrinkingPolicy: ShrinkingPolicy
              .off, // needed to avoid a RangeError that was happening
          combine2(quotifyBackupGenerator(), privacyDataGenerator()),
          (pair) async {
            final backup = pair.$1;
            var privacyData = pair.$2;

            if (backup.privacyData == privacyData) {
              log(
                "Generated Backup's privacy data and generated privacy data are equal, "
                'toggling parameters of generated privacy data',
              );
              privacyData = privacyData.copyWith(
                acceptedDataUsage: !privacyData.acceptedDataUsage,
                allowErrorReporting: !privacyData.allowErrorReporting,
              );
            }
            final backupPrivacyDataEntry = backup.privacyData
                .toPrivacyDataEntry();

            when(
              privacyRepository.fetchPrivacyData,
            ).thenAnswer((_) async => Result.ok(privacyData));
            when(
              () => privacyRepository.savePrivacyData(any()),
            ).thenAnswer((_) async => const Result.ok(()));

            final useCase = RestoreBackup(
              backup: backup,
              quotesRepository: quotesRepository,
              tagRepository: tagRepository,
              languagesRepository: languagesRepository,
              primaryColorsRepository: primaryColorsRepository,
              privacyRepository: privacyRepository,
              themeBrightnessRepository: themeBrightnessRepository,
              themeBrightnessDataSourceToUse: DataSourceToUse.values
                  .sample(1)
                  .single,
              primaryColorDataSourceToUse: DataSourceToUse.values
                  .sample(1)
                  .single,
              languageDataSourceToUse: DataSourceToUse.values.sample(1).single,
              privacyDataDataSourceToUse: DataSourceToUse.backup,
              tagsConflictResolver: ConflictResolver.values.sample(1).single,
              quotesConflictResolver: ConflictResolver.values.sample(1).single,
            );

            final result = await useCase.privacyDataRestore();

            check(result).isA<Ok<(), PrivacyDataErrors>>();

            verify(privacyRepository.fetchPrivacyData).called(1);
            verify(
              () => privacyRepository.savePrivacyData(backupPrivacyDataEntry),
            ).called(1);
          },
        ),
      );
    });
  });
}
