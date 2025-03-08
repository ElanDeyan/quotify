import 'dart:math';

import 'package:backup_logic/backup_logic.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';

void main() {
  const seed = 50;
  final random = Random(seed);
  group('toMap', () {
    test('should contain 6 keys', () {
      final sample = _backupWithDefaultData();

      expect(sample.toMap().keys, hasLength(6));
    });

    group('string values', () {
      test('themeBrightness value should be a valid member name', () {
        for (final themeBrightness in ThemeBrightness.values) {
          final sample = _backupWithDefaultData().copyWith(
            themeBrightness: themeBrightness,
          );

          expect(
            sample.toMap()[ThemeBrightness.jsonKey],
            equals(themeBrightness.name),
          );
        }
      });
      test('primaryColor value should be a valid member name', () {
        for (final primaryColor in PrimaryColors.values) {
          final sample = _backupWithDefaultData().copyWith(
            primaryColor: primaryColor,
          );

          expect(
            sample.toMap()[PrimaryColors.jsonKey],
            equals(primaryColor.name),
          );
        }
      });
      test('languages value should be a valid member language code', () {
        for (final language in Languages.values) {
          final sample = _backupWithDefaultData().copyWith(language: language);

          expect(
            sample.toMap()[Languages.jsonKey],
            equals(language.languageCode),
          );
        }
      });
    });

    group('map values', () {
      test('privacyData should be valid', () {
        final samplePrivacyData = PrivacyData(
          allowErrorReporting: random.nextBool(),
          acceptedDataUsage: random.nextBool(),
        );

        final sampleBackup = _backupWithDefaultData().copyWith(
          privacyData: samplePrivacyData,
        );

        expect(
          sampleBackup.toMap()[PrivacyData.jsonKey],
          equals(samplePrivacyData.toMap()),
        );
      });
    });

    group('list of maps', () {
      group('tags', () {
        test('should be valid list of maps', () {
          const tagsQuantity = 5;
          final tags = <Tag>{
            for (var i = 0; i < tagsQuantity; i++)
              Tag(
                id: Id(Natural(faker.randomGenerator.integer(50))),
                label: NonBlankString(faker.lorem.word()),
              ),
          };
          final sampleBackup = _backupWithDefaultData().copyWith(
            tags: UnmodifiableSetView(tags),
          );

          final tagsFromBackupMap = sampleBackup.toMap()[Tag.listOfTagsJsonKey];

          expect(
            tagsFromBackupMap,
            allOf([
              isA<List<Map<String, Object?>>>(),
              hasLength(tagsQuantity),
              equals(tags.map((e) => e.toMap()).toList()),
            ]),
          );
        });

        test('should be empty list if there are no tags', () {
          const tags = <Tag>{};

          final sampleBackup = _backupWithDefaultData().copyWith(
            tags: UnmodifiableSetView(tags),
          );

          expect(
            sampleBackup.toMap()[Tag.listOfTagsJsonKey],
            allOf([isA<List<Map<String, Object?>>>(), isEmpty]),
          );
        });
      });
      group('quotes', () {
        test('should be valid list of maps', () {
          const quotesQuantity = 5;
          final quotes = <Quote>{
            for (var i = 0; i < quotesQuantity; i++)
              Quote(
                id: Id(Natural(faker.randomGenerator.integer(50))),
                content: NonBlankString(faker.lorem.sentence()),
                author: NonBlankString(faker.person.name()),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now().add(const Duration(minutes: 5)),
              ),
          };
          final sampleBackup = _backupWithDefaultData().copyWith(
            quotes: UnmodifiableSetView(quotes),
          );

          final quotesFromBackupMap =
              sampleBackup.toMap()[Quote.listOfQuotesJsonKey];

          expect(
            quotesFromBackupMap,
            allOf([
              isA<List<Map<String, Object?>>>(),
              hasLength(quotesQuantity),
              equals(quotes.map((e) => e.toMap()).toList()),
            ]),
          );
        });

        test('should be empty list if there are no quotes', () {
          const quotes = <Quote>{};

          final sampleBackup = _backupWithDefaultData().copyWith(
            quotes: UnmodifiableSetView(quotes),
          );

          expect(
            sampleBackup.toMap()[Quote.listOfQuotesJsonKey],
            allOf([isA<List<Map<String, Object?>>>(), isEmpty]),
          );
        });
      });
    });
  });

  group('fromMap', () {
    test('empty map should return failure', () {
      final backupFromEmptyMap = Backup.fromMap({});

      expect(backupFromEmptyMap, isA<Failure<Backup, BackupModelErrors>>());
      expect(
        backupFromEmptyMap.asFailure.failure,
        equals(BackupModelErrors.invalidMapRepresentation),
      );
    });

    group('if missing any key', () {
      test('like ${ThemeBrightness.jsonKey}, should return failure with'
          ' ${BackupModelErrors.invalidMapRepresentation}', () {
        final sampleBackupMapWithoutId =
            _backupWithDefaultData().toMap()..remove(ThemeBrightness.jsonKey);

        final fromMap = Backup.fromMap(sampleBackupMapWithoutId);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidMapRepresentation),
        );
      });
      test('like ${PrimaryColors.jsonKey}, should return failure with'
          ' ${BackupModelErrors.invalidMapRepresentation}', () {
        final sampleBackupMapWithoutId =
            _backupWithDefaultData().toMap()..remove(PrimaryColors.jsonKey);

        final fromMap = Backup.fromMap(sampleBackupMapWithoutId);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidMapRepresentation),
        );
      });
      test('like ${Languages.jsonKey}, should return failure with'
          ' ${BackupModelErrors.invalidMapRepresentation}', () {
        final sampleBackupMapWithoutId =
            _backupWithDefaultData().toMap()..remove(Languages.jsonKey);

        final fromMap = Backup.fromMap(sampleBackupMapWithoutId);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidMapRepresentation),
        );
      });
      test('like ${PrivacyData.jsonKey}, should return failure with'
          ' ${BackupModelErrors.invalidMapRepresentation}', () {
        final sampleBackupMapWithoutId =
            _backupWithDefaultData().toMap()..remove(PrivacyData.jsonKey);

        final fromMap = Backup.fromMap(sampleBackupMapWithoutId);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidMapRepresentation),
        );
      });
      test('like ${Tag.listOfTagsJsonKey}, should return failure with'
          ' ${BackupModelErrors.invalidMapRepresentation}', () {
        final sampleBackupMapWithoutId =
            _backupWithDefaultData().toMap()..remove(Tag.listOfTagsJsonKey);

        final fromMap = Backup.fromMap(sampleBackupMapWithoutId);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidMapRepresentation),
        );
      });
      test('like ${Quote.listOfQuotesJsonKey}, should return failure with'
          ' ${BackupModelErrors.invalidMapRepresentation}', () {
        final sampleBackupMapWithoutId =
            _backupWithDefaultData().toMap()..remove(Quote.listOfQuotesJsonKey);

        final fromMap = Backup.fromMap(sampleBackupMapWithoutId);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidMapRepresentation),
        );
      });
    });

    group('if some value is invalid', () {
      test('like themeBrightness should return Failure '
          'with invalidThemeBrightness', () {
        final word = faker.lorem.word();

        assert(
          !ThemeBrightness.values.map((e) => e.name).contains(word),
          'ensure that random value is not valid',
        );
        final sampleBackupWithWrongThemeBrightness =
            _backupWithDefaultData().toMap()
              ..update(ThemeBrightness.jsonKey, (_) => word);

        final fromMap = Backup.fromMap(sampleBackupWithWrongThemeBrightness);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidThemeBrightness),
        );
      });
      test('like primaryColors should return Failure '
          'with ${BackupModelErrors.invalidPrimaryColor.name}', () {
        final word = faker.lorem.word();

        assert(
          !PrimaryColors.values.map((e) => e.name).contains(word),
          'ensure that random value is not valid',
        );
        final sampleBackupWithWrongPrimaryColor =
            _backupWithDefaultData().toMap()
              ..update(PrimaryColors.jsonKey, (_) => word);

        final fromMap = Backup.fromMap(sampleBackupWithWrongPrimaryColor);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidPrimaryColor),
        );
      });
      test('like language should return Failure '
          'with ${BackupModelErrors.invalidLanguageCode.name}', () {
        final word = faker.lorem.word();

        assert(
          !Languages.values.map((e) => e.name).contains(word),
          'ensure that random value is not valid',
        );
        final sampleBackupWithWrongLanguage =
            _backupWithDefaultData().toMap()
              ..update(Languages.jsonKey, (_) => word);

        final fromMap = Backup.fromMap(sampleBackupWithWrongLanguage);

        expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
        expect(
          fromMap.asFailure.failure,
          equals(BackupModelErrors.invalidLanguageCode),
        );
      });
      test('like privacyData should return Failure '
          'with ${BackupModelErrors.invalidPrivacyDataMap.name}', () {
        const privacyData = PrivacyData.initial();

        final wrongMapSamples = <Map<String, Object?>>[
          privacyData.toMap()..remove(PrivacyRepository.allowErrorReportingKey),
          privacyData.toMap()..remove(PrivacyRepository.acceptedDataUsageKey),
          privacyData.toMap()..update(
            PrivacyRepository.acceptedDataUsageKey,
            (value) => faker.lorem.word(),
          ),
          privacyData.toMap()..update(
            PrivacyRepository.allowErrorReportingKey,
            (value) => faker.lorem.word(),
          ),
        ];

        for (final sample in wrongMapSamples) {
          final sampleBackupWithWrongLanguage =
              _backupWithDefaultData().toMap()
                ..update(PrivacyData.jsonKey, (_) => sample);

          final fromMap = Backup.fromMap(sampleBackupWithWrongLanguage);

          expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
          expect(
            fromMap.asFailure.failure,
            equals(BackupModelErrors.invalidPrivacyDataMap),
          );
        }
      });
      test('like tags should return Failure '
          'with ${BackupModelErrors.atLeastOneInvalidTagMap.name}', () {
        for (var i = 0; i < 5; i++) {
          final sampleBackupWithWrongTagMap =
              _backupWithDefaultData().toMap()..update(
                Tag.listOfTagsJsonKey,
                (_) => _wrongTagsMapList()..shuffle(random),
              );

          final fromMap = Backup.fromMap(sampleBackupWithWrongTagMap);

          expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
          expect(
            fromMap.asFailure.failure,
            equals(BackupModelErrors.atLeastOneInvalidTagMap),
          );
        }
      });
      test('like quotes should return Failure '
          'with ${BackupModelErrors.atLeastOneInvalidQuoteMap.name}', () {
        for (var i = 0; i < 5; i++) {
          final sampleBackupWithWrongQuotesMap =
              _backupWithDefaultData().toMap()..update(
                Quote.listOfQuotesJsonKey,
                (_) => _wrongQuotesMapSample()..shuffle(random),
              );

          final fromMap = Backup.fromMap(sampleBackupWithWrongQuotesMap);

          expect(fromMap, isA<Failure<Backup, BackupModelErrors>>());
          expect(
            fromMap.asFailure.failure,
            equals(BackupModelErrors.atLeastOneInvalidQuoteMap),
          );
        }
      });
    });
    group('if is valid', () {
      test('should return OK with the backup data', () {
        final backupWithDefaultData = _backupWithDefaultData();

        final sampleMap = backupWithDefaultData.toMap();

        final result = Backup.fromMap(sampleMap);

        expect(result, isA<Ok<Backup, BackupModelErrors>>());
        expect(result.asOk.value, equals(backupWithDefaultData));
      });
    });
  });

  group('fromJsonString', () {
    test(
      'when not valid json string return failure with invalidJsonString',
      () {
        final result = Backup.fromJsonString('true');

        expect(result, isA<Failure<Backup, BackupModelErrors>>());
        expect(result.asFailure.failure, BackupModelErrors.invalidJsonString);
      },
    );

    test('when not a json map return failure with invalidJsonString', () {
      final result = Backup.fromJsonString('[{"key": 10}]');

      expect(result, isA<Failure<Backup, BackupModelErrors>>());
      expect(result.asFailure.failure, BackupModelErrors.invalidJsonString);
    });

    test('when is a json map return Result of fromMap', () {
      final backupWithDefaultData = _backupWithDefaultData();
      final sampleJsonString = backupWithDefaultData.toJsonString();
      final result = Backup.fromJsonString(sampleJsonString);

      expect(result, isA<Ok<Backup, BackupModelErrors>>());
      expect(result.asOk.value, backupWithDefaultData);
    });
  });
}

Backup _backupWithDefaultData() => const Backup(
  themeBrightness: ThemeBrightness.defaultTheme,
  primaryColor: PrimaryColors.defaultColor,
  language: Languages.defaultLanguage,
  privacyData: PrivacyData.initial(),
  tags: UnmodifiableSetView.empty(),
  quotes: UnmodifiableSetView.empty(),
);

List<Map<String, Object?>> _wrongTagsMapList() {
  final negativeId = _sampleTag().toMap()..update('id', (_) => -5);

  final emptyLabel = _sampleTag().toMap()..update('label', (_) => '');

  final blankLabel = _sampleTag().toMap()..update('label', (_) => '    ');

  final withoutId = _sampleTag().toMap()..remove('id');
  final withoutLabel = _sampleTag().toMap()..remove('label');

  return [negativeId, emptyLabel, blankLabel, withoutLabel, withoutId];
}

Tag _sampleTag() => Tag(
  id: Id(Natural(faker.randomGenerator.integer(100))),
  label: NonBlankString(faker.lorem.word()),
);

Quote _sampleQuote() {
  final sampleTagsLength = faker.randomGenerator.integer(10);
  return Quote(
    id: Id(Natural(faker.randomGenerator.integer(100))),
    content: NonBlankString(faker.lorem.sentence()),
    author: NonBlankString(faker.person.name()),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now().add(const Duration(minutes: 5)),
    isFavorite: faker.randomGenerator.boolean(),
    source: faker.randomGenerator.boolean() ? faker.lorem.word() : null,
    sourceUri:
        faker.randomGenerator.boolean()
            ? Uri.tryParse(faker.internet.httpsUrl())
            : null,
    tags:
        faker.randomGenerator.boolean()
            ? UnmodifiableSetView({
              for (var i = 0; i < sampleTagsLength; i++) _sampleTag(),
            })
            : const UnmodifiableSetView.empty(),
  );
}

List<Map<String, Object?>> _wrongQuotesMapSample() {
  final withoutId = _sampleQuote().toMap()..remove('id');
  final withNegativeId =
      _sampleQuote().toMap()
        ..update('id', (_) => faker.randomGenerator.integer(-1, min: -20));
  final withoutContent = _sampleQuote().toMap()..remove('content');
  final withEmptyContent = _sampleQuote().toMap()..update('content', (_) => '');
  final withBlankContent =
      _sampleQuote().toMap()..update('content', (_) => '    ');
  final withoutAuthor = _sampleQuote().toMap()..remove('author');
  final withEmptyAuthor = _sampleQuote().toMap()..update('author', (_) => '');
  final withBlankAuthor =
      _sampleQuote().toMap()..update('author', (_) => '   ');
  final withoutSource = _sampleQuote().toMap()..remove('source');
  final withEmptySource = _sampleQuote().toMap()..update('source', (_) => '');
  final withBlankSource =
      _sampleQuote().toMap()..update('source', (_) => '   ');
  final withoutSourceUri = _sampleQuote().toMap()..remove('sourceUri');
  final withInvalidSourceUri =
      _sampleQuote().toMap()..update('sourceUri', (_) => '::Not valid URI::');
  final withoutIsFavorite = _sampleQuote().toMap()..remove('isFavorite');
  final withoutCreatedAt = _sampleQuote().toMap()..remove('createdAt');
  final withInvalidCreatedAtString =
      _sampleQuote().toMap()..update('createdAt', (_) => faker.lorem.word());
  final withoutUpdatedAt = _sampleQuote().toMap()..remove('updatedAt');
  final withInvalidUpdatedAtString =
      _sampleQuote().toMap()..update('updatedAt', (_) => faker.lorem.word());
  final withoutTags = _sampleQuote().toMap()..remove('tags');
  final withInvalidTagMap =
      _sampleQuote().toMap()..update('tags', (_) => _wrongTagsMapList());

  return [
    withoutId,
    withNegativeId,
    withoutContent,
    withEmptyContent,
    withBlankContent,
    withoutAuthor,
    withEmptyAuthor,
    withBlankAuthor,
    withoutSource,
    withEmptySource,
    withBlankSource,
    withoutSourceUri,
    withInvalidSourceUri,
    withoutIsFavorite,
    withoutCreatedAt,
    withInvalidCreatedAtString,
    withoutUpdatedAt,
    withInvalidUpdatedAtString,
    withoutTags,
    withInvalidTagMap,
  ];
}
