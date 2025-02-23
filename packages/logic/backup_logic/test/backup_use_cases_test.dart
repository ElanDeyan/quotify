import 'package:backup_logic/backup_logic.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:languages_repository/repositories/languages_repository_errors.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository_errors.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/repositories/privacy_data_repository_errors.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/repositories/quotes_repository.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/repositories/tag_repository.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository_errors.dart';

import 'mocks/repository_mocks.dart';
import 'utils/sample_quote_generator.dart';
import 'utils/sample_tag_generator.dart';

void main() {
  group('fetchBackupData', () {
    late MockThemeBrightnessRepository themeBrightnessRepository;
    late MockPrimaryColorsRepository primaryColorsRepository;
    late MockLanguagesRepository languagesRepository;
    late MockPrivacyRepository privacyRepository;
    late MockTagRepository tagRepository;
    late MockQuotesRepository quotesRepository;

    late FetchBackupData fetchBackupData;

    setUp(() {
      themeBrightnessRepository = MockThemeBrightnessRepository();
      primaryColorsRepository = MockPrimaryColorsRepository();
      languagesRepository = MockLanguagesRepository();
      privacyRepository = MockPrivacyRepository();
      tagRepository = MockTagRepository();
      quotesRepository = MockQuotesRepository();

      fetchBackupData = FetchBackupData(
        quotesRepository: quotesRepository,
        tagRepository: tagRepository,
        languagesRepository: languagesRepository,
        primaryColorsRepository: primaryColorsRepository,
        privacyRepository: privacyRepository,
        themeBrightnessRepository: themeBrightnessRepository,
      );
    });

    group('with failure when request repositories', () {
      test(
        'like themeBrightnessRepository '
        'should return failure with failAtRequestingThemeBrightnessRepository',
        () async {
          _setUpFetchThemeBrightness(
            themeBrightnessRepository,
            successful: false,
          );
          _setUpFetchPrimaryColor(primaryColorsRepository);
          _setUpFetchCurrentLanguage(languagesRepository);
          _setUpFetchPrivacyData(privacyRepository);
          _setUpAllTags(
            tagRepository,
            quantity: Natural(faker.randomGenerator.integer(10)),
          );
          _setUpAllQuotes(quotesRepository);

          final result = await fetchBackupData();

          expect(result, isA<Failure<Backup, BackupUseCasesErrors>>());
          expect(
            result.asFailure.failure,
            equals(
              BackupUseCasesErrors.failAtRequestingThemeBrightnessRepository,
            ),
          );
        },
      );
      test(
        'like primaryColorRepository '
        'should return failure with failAtRequestingPrimaryColorsRepository',
        () async {
          _setUpFetchThemeBrightness(themeBrightnessRepository);
          _setUpFetchPrimaryColor(primaryColorsRepository, successful: false);
          _setUpFetchCurrentLanguage(languagesRepository);
          _setUpFetchPrivacyData(privacyRepository);
          _setUpAllTags(
            tagRepository,
            quantity: Natural(faker.randomGenerator.integer(10)),
          );
          _setUpAllQuotes(
            quotesRepository,
            quantity: Natural(faker.randomGenerator.integer(10)),
          );

          final result = await fetchBackupData();

          expect(result, isA<Failure<Backup, BackupUseCasesErrors>>());
          expect(
            result.asFailure.failure,
            equals(
              BackupUseCasesErrors.failAtRequestingPrimaryColorsRepository,
            ),
          );
        },
      );

      test(
        'like languagesRepository '
        'should return failure with failAtRequestingLanguagesRepository',
        () async {
          _setUpFetchThemeBrightness(themeBrightnessRepository);
          _setUpFetchPrimaryColor(primaryColorsRepository);
          _setUpFetchCurrentLanguage(languagesRepository, successful: false);
          _setUpFetchPrivacyData(privacyRepository);
          _setUpAllTags(
            tagRepository,
            quantity: Natural(faker.randomGenerator.integer(10)),
          );
          _setUpAllQuotes(
            quotesRepository,
            quantity: Natural(faker.randomGenerator.integer(10)),
          );

          final result = await fetchBackupData();

          expect(result, isA<Failure<Backup, BackupUseCasesErrors>>());
          expect(
            result.asFailure.failure,
            equals(BackupUseCasesErrors.failAtRequestingLanguagesRepository),
          );
        },
      );

      test(
        'like privacyRepository '
        'should return failure with failAtRequestingPrivacyRepository',
        () async {
          _setUpFetchThemeBrightness(themeBrightnessRepository);
          _setUpFetchPrimaryColor(primaryColorsRepository);
          _setUpFetchCurrentLanguage(languagesRepository);
          _setUpFetchPrivacyData(privacyRepository, successful: false);
          _setUpAllTags(
            tagRepository,
            quantity: Natural(faker.randomGenerator.integer(10)),
          );
          _setUpAllQuotes(
            quotesRepository,
            quantity: Natural(faker.randomGenerator.integer(10)),
          );

          final result = await fetchBackupData();

          expect(result, isA<Failure<Backup, BackupUseCasesErrors>>());
          expect(
            result.asFailure.failure,
            equals(BackupUseCasesErrors.failAtRequestingPrivacyRepository),
          );
        },
      );
    });

    group('when not fails', () {
      test('should return Ok with the backup data', () async {
        final tagsQuantity = Natural(faker.randomGenerator.integer(10));
        final quotesQuantity = Natural(faker.randomGenerator.integer(10));

        _setUpFetchThemeBrightness(themeBrightnessRepository);
        _setUpFetchPrimaryColor(primaryColorsRepository);
        _setUpFetchCurrentLanguage(languagesRepository);
        _setUpFetchPrivacyData(privacyRepository);
        _setUpAllTags(tagRepository, quantity: tagsQuantity);
        _setUpAllQuotes(quotesRepository, quantity: quotesQuantity);

        final result = await fetchBackupData();

        expect(result, isA<Ok<Backup, BackupUseCasesErrors>>());

        final Backup(:tags, :quotes) = result.asOk.value;

        expect(tags, hasLength(tagsQuantity));
        expect(quotes, hasLength(quotesQuantity));
      });
    });
  });
}

void _setUpFetchThemeBrightness(
  ThemeBrightnessRepository mockThemeBrightness, {
  bool successful = true,
}) {
  switch (successful) {
    case true:
      when(
        () => mockThemeBrightness.fetchThemeBrightness(),
      ).thenAnswer((_) async => const Ok(ThemeBrightness.defaultTheme));
    case false:
      when(() => mockThemeBrightness.fetchThemeBrightness()).thenAnswer(
        (_) async => const Failure(ThemeBrightnessRepositoryErrors.missing),
      );
  }
}

void _setUpFetchPrimaryColor(
  PrimaryColorsRepository mockPrimaryColorRepository, {
  bool successful = true,
}) {
  switch (successful) {
    case true:
      when(
        () => mockPrimaryColorRepository.fetchPrimaryColor(),
      ).thenAnswer((_) async => const Ok(PrimaryColors.fireEngineRed));
    case false:
      when(() => mockPrimaryColorRepository.fetchPrimaryColor()).thenAnswer(
        (_) async => const Failure(PrimaryColorsRepositoryErrors.failAtSaving),
      );
  }
}

void _setUpFetchCurrentLanguage(
  LanguagesRepository mockLanguagesRepository, {
  bool successful = true,
}) {
  switch (successful) {
    case true:
      when(
        () => mockLanguagesRepository.fetchCurrentLanguage(),
      ).thenAnswer((_) async => const Ok(Languages.brazilianPortuguese));
    case false:
      when(() => mockLanguagesRepository.fetchCurrentLanguage()).thenAnswer(
        (_) async =>
            const Failure(LanguagesRepositoryErrors.missingLanguageCode),
      );
  }
}

void _setUpFetchPrivacyData(
  PrivacyRepository mockPrivacyData, {
  bool successful = true,
}) {
  switch (successful) {
    case true:
      when(
        () => mockPrivacyData.fetchPrivacyData(),
      ).thenAnswer((_) async => const Ok(PrivacyData.initial()));
    case false:
      when(() => mockPrivacyData.fetchPrivacyData()).thenAnswer(
        (_) async => const Failure(PrivacyRepositoryErrors.failAtWriting),
      );
  }
}

void _setUpAllTags(
  TagRepository tagRepository, {
  Natural quantity = const Natural(0),
}) {
  if (quantity == const Natural(0)) {
    when(
      () => tagRepository.allTags,
    ).thenAnswer((_) async => UnmodifiableListView(const Iterable.empty()));
    return;
  }

  when(() => tagRepository.allTags).thenAnswer(
    (_) async => UnmodifiableListView(
      Iterable.generate(quantity, (_) => sampleTagGenerator()),
    ),
  );
}

void _setUpAllQuotes(
  QuotesRepository quotesRepository, {
  Natural quantity = const Natural(0),
  bool containsSource = false,
  bool containsSourceUri = false,
  Natural howManyTags = const Natural(0),
}) {
  if (quantity == const Natural(0)) {
    when(
      () => quotesRepository.allQuotes,
    ).thenAnswer((_) async => UnmodifiableListView(const Iterable.empty()));
    return;
  }

  when(() => quotesRepository.allQuotes).thenAnswer(
    (_) async => UnmodifiableListView(
      Iterable.generate(
        quantity,
        (_) => sampleQuoteGenerator(
          containsSource: containsSource,
          containsSourceUri: containsSourceUri,
          howManyTags: howManyTags,
        ),
      ),
    ),
  );
}
