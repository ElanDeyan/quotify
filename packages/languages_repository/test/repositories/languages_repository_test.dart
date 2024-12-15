import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:languages_repository/models/language_errors.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:languages_repository/repositories/languages_repository_errors.dart';
import 'package:languages_repository/repositories/languages_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:shared_preferences_service/shared_preferences_async_service.dart';
import 'package:shared_preferences_service_test/mock_shared_preferences_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesAsyncService sharedPreferencesAsyncService;
  late LanguagesRepository languagesRepository;

  setUp(() {
    sharedPreferencesAsyncService =
        SharedPreferencesAsyncService(MockSharedPreferencesAsync());
    languagesRepository = LanguagesRepositoryImpl(
      sharedPreferencesAsyncService,
    );
  });

  group('initialize', () {
    test('when does not have an existent value, sets defaultLanguage',
        () async {
      when(
        () => sharedPreferencesAsyncService
            .containsKey(LanguagesRepository.languageKey),
      ).thenAnswer((_) async => false);
      when(
        () => sharedPreferencesAsyncService.setString(
          LanguagesRepository.languageKey,
          Languages.defaultLanguage.languageCode,
        ),
      ).thenAnswer((_) async {});

      await languagesRepository.initialize();

      verify(
        () => sharedPreferencesAsyncService
            .containsKey(LanguagesRepository.languageKey),
      ).called(1);

      verify(
        () => sharedPreferencesAsyncService.setString(
          LanguagesRepository.languageKey,
          Languages.defaultLanguage.languageCode,
        ),
      ).called(1);
    });

    test('when have an existent value, not changes', () async {
      when(
        () => sharedPreferencesAsyncService
            .containsKey(LanguagesRepository.languageKey),
      ).thenAnswer((_) async => true);

      await languagesRepository.initialize();

      verify(
        () => sharedPreferencesAsyncService
            .containsKey(LanguagesRepository.languageKey),
      ).called(1);

      verifyNever(
        () => sharedPreferencesAsyncService.setString(
          LanguagesRepository.languageKey,
          Languages.defaultLanguage.languageCode,
        ),
      );
    });
  });

  group('fetchCurrentLanguage', () {
    tearDown(() {
      verifyNever(
        () => sharedPreferencesAsyncService.setString(
          LanguagesRepository.languageKey,
          any(),
        ),
      );
    });
    test(
      'without an already existent value should return a '
      'Failure with LanguagesRepositoryErrors.missingLanguageCode',
      () async {
        when(
          () => sharedPreferencesAsyncService.containsKey(
            LanguagesRepository.languageKey,
          ),
        ).thenAnswer((_) async => false);

        final result = await languagesRepository.fetchCurrentLanguage();

        expect(result, isA<Failure<Languages>>());
        expect(
          result.asFailure.failure,
          equals(LanguagesRepositoryErrors.missingLanguageCode),
        );

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            LanguagesRepository.languageKey,
          ),
        ).called(1);

        verifyNever(
          () => sharedPreferencesAsyncService.getString(
            LanguagesRepository.languageKey,
          ),
        );
      },
    );

    test(
      'with an existent value, should return Ok with the Language',
      () async {
        const sample = Languages.brazilianPortuguese;

        when(
          () => sharedPreferencesAsyncService.containsKey(
            LanguagesRepository.languageKey,
          ),
        ).thenAnswer((_) async => true);
        when(
          () => sharedPreferencesAsyncService.getString(
            LanguagesRepository.languageKey,
          ),
        ).thenAnswer((_) async => sample.languageCode);

        final result = await languagesRepository.fetchCurrentLanguage();

        expect(result, isA<Ok<Languages>>());
        expect(result.asOk.value, equals(sample));

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            LanguagesRepository.languageKey,
          ),
        ).called(1);
        verify(
          () => sharedPreferencesAsyncService.getString(
            LanguagesRepository.languageKey,
          ),
        ).called(1);
      },
    );
    test(
      'with an invalid existent value, should return Failure '
      'with the LanguagesErrors.invalidLanguageCodeRepresentation',
      () async {
        final sample = faker.lorem.word();

        assert(
          !Languages.values.map((color) => color.languageCode).contains(sample),
          'Should be an invalid name for this test',
        );

        when(
          () => sharedPreferencesAsyncService.containsKey(
            LanguagesRepository.languageKey,
          ),
        ).thenAnswer((_) async => true);
        when(
          () => sharedPreferencesAsyncService.getString(
            LanguagesRepository.languageKey,
          ),
        ).thenAnswer((_) async => sample);

        final result = await languagesRepository.fetchCurrentLanguage();

        expect(result, isA<Failure<Languages>>());
        expect(
          result.asFailure.failure,
          equals(LanguageErrors.invalidLanguageCodeRepresentation),
        );

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            LanguagesRepository.languageKey,
          ),
        ).called(1);
        verify(
          () => sharedPreferencesAsyncService.getString(
            LanguagesRepository.languageKey,
          ),
        ).called(1);
      },
    );
  });

  group('setCurrentLanguage', () {
    group('whatever it has an already value or not', () {
      test('should write the desired value', () async {
        const sample = Languages.english;
        when(
          () => sharedPreferencesAsyncService.setString(
            LanguagesRepository.languageKey,
            sample.languageCode,
          ),
        ).thenAnswer((_) async {});

        final result = await languagesRepository.setCurrentLanguage(sample);

        expect(result, isA<Ok<void>>());

        verify(
          () => sharedPreferencesAsyncService.setString(
            LanguagesRepository.languageKey,
            sample.languageCode,
          ),
        ).called(1);

        verifyNever(
          () => sharedPreferencesAsyncService.containsKey(
            LanguagesRepository.languageKey,
          ),
        );
        verifyNever(
          () => sharedPreferencesAsyncService.getString(
            LanguagesRepository.languageKey,
          ),
        );
      });
    });
    group('if something went wrong on saving', () {
      test(
        'should return a Failure with '
        'LanguagesRepositoryErrors.failAtSaving',
        () async {
          const sample = Languages.spanish;

          when(
            () => sharedPreferencesAsyncService.setString(
              LanguagesRepository.languageKey,
              any(),
            ),
          ).thenThrow(Exception('oops'));

          final result = await languagesRepository.setCurrentLanguage(sample);

          expect(result, isA<Failure<void>>());

          verify(
            () => sharedPreferencesAsyncService.setString(
              LanguagesRepository.languageKey,
              sample.languageCode,
            ),
          ).called(1);

          verifyNever(
            () => sharedPreferencesAsyncService.containsKey(
              LanguagesRepository.languageKey,
            ),
          );
          verifyNever(
            () => sharedPreferencesAsyncService.getString(
              LanguagesRepository.languageKey,
            ),
          );
        },
      );
    });
  });
}
