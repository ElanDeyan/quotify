import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quotify/features/core/services/notifier.dart';
import 'package:quotify/features/core/services/shared_preferences_async_service.dart';
import 'package:quotify/features/theme_brightness/logic/models/theme_brightness.dart';
import 'package:quotify/features/theme_brightness/logic/models/theme_brightness_errors.dart';
import 'package:quotify/features/theme_brightness/repositories/theme_brightness_repository.dart';
import 'package:quotify/features/theme_brightness/repositories/theme_brightness_repository_errors.dart';
import 'package:quotify/features/theme_brightness/repositories/theme_brightness_repository_impl.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../../../core/mock_shared_preferences_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferencesAsyncService sharedPreferencesAsyncService;
  late ThemeBrightnessRepository themeBrightnessRepository;
  setUp(() {
    sharedPreferencesAsyncService =
        SharedPreferencesAsyncService(MockSharedPreferencesAsync());
    themeBrightnessRepository = ThemeBrightnessRepositoryImpl(
      sharedPreferencesAsyncService,
      notifier: notifier,
    );
  });

  group('initialize', () {
    test('when does not have an existent value, sets defaultTheme', () async {
      when(
        () => sharedPreferencesAsyncService.containsKey(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
        ),
      ).thenAnswer((_) async => false);
      when(
        () => sharedPreferencesAsyncService.setString(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ThemeBrightness.defaultTheme.name,
        ),
      ).thenAnswer((_) async {});

      await themeBrightnessRepository.initialize();

      verify(
        () => sharedPreferencesAsyncService.containsKey(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
        ),
      ).called(1);

      verify(
        () => sharedPreferencesAsyncService.setString(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ThemeBrightness.defaultTheme.name,
        ),
      ).called(1);
    });

    test('when have an existent value, not changes', () async {
      when(
        () => sharedPreferencesAsyncService.containsKey(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
        ),
      ).thenAnswer((_) async => true);

      await themeBrightnessRepository.initialize();

      verify(
        () => sharedPreferencesAsyncService.containsKey(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
        ),
      ).called(1);

      verifyNever(
        () => sharedPreferencesAsyncService.setString(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ThemeBrightness.defaultTheme.name,
        ),
      );
    });
  });

  group('fetchThemeBrightness', () {
    tearDown(() {
      verifyNever(
        () => sharedPreferencesAsyncService.setString(
          ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          any(),
        ),
      );
    });
    test(
      'without an already existent value should return a '
      'Failure with ThemeBrightnessRepositoryError.missing',
      () async {
        when(
          () => sharedPreferencesAsyncService.containsKey(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).thenAnswer((_) async => false);

        final result = await themeBrightnessRepository.fetchThemeBrightness();

        expect(result, isA<Failure<ThemeBrightness>>());
        expect(
          result.asFailure.failure,
          equals(ThemeBrightnessRepositoryErrors.missing),
        );

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).called(1);

        verifyNever(
          () => sharedPreferencesAsyncService.getString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        );
      },
    );

    test(
      'with an existent value, should return Ok with the ThemeBrightness',
      () async {
        const sample = ThemeBrightness.dark;
        when(
          () => sharedPreferencesAsyncService.containsKey(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).thenAnswer((_) async => true);
        when(
          () => sharedPreferencesAsyncService.getString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).thenAnswer((_) async => sample.name);

        final result = await themeBrightnessRepository.fetchThemeBrightness();

        expect(result, isA<Ok<ThemeBrightness>>());
        expect(result.asOk.value, equals(sample));

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).called(1);
        verify(
          () => sharedPreferencesAsyncService.getString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).called(1);
      },
    );
    test(
      'with an invalid existent value, should return Failure '
      'with the ThemeBrightnessErrors.invalidStringRepresentation',
      () async {
        final sample = faker.lorem.word();

        assert(
          !ThemeBrightness.values.map((theme) => theme.name).contains(sample),
          'Should be an invalid name for this test',
        );

        when(
          () => sharedPreferencesAsyncService.containsKey(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).thenAnswer((_) async => true);
        when(
          () => sharedPreferencesAsyncService.getString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).thenAnswer((_) async => sample);

        final result = await themeBrightnessRepository.fetchThemeBrightness();

        expect(result, isA<Failure<ThemeBrightness>>());
        expect(
          result.asFailure.failure,
          equals(ThemeBrightnessErrors.invalidStringRepresentation),
        );

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).called(1);
        verify(
          () => sharedPreferencesAsyncService.getString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        ).called(1);
      },
    );
  });

  group('saveThemeBrightness', () {
    group('whatever it has an already value or not', () {
      test('should write the desired value', () async {
        const sample = ThemeBrightness.system;
        when(
          () => sharedPreferencesAsyncService.setString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
            sample.name,
          ),
        ).thenAnswer((_) async {});

        final result =
            await themeBrightnessRepository.saveThemeBrightness(sample);

        expect(result, isA<Ok<void>>());

        verify(
          () => sharedPreferencesAsyncService.setString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
            sample.name,
          ),
        ).called(1);

        verifyNever(
          () => sharedPreferencesAsyncService.containsKey(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        );
        verifyNever(
          () => sharedPreferencesAsyncService.getString(
            ThemeBrightnessRepository.themeBrightnessRepositoryKey,
          ),
        );
      });
    });
    group('if something went wrong on saving', () {
      test(
        'should return a Failure with '
        'ThemeBrightnessRepositoryErrors.failAtSaving',
        () async {
          const sample = ThemeBrightness.dark;
          when(
            () => sharedPreferencesAsyncService.setString(
              ThemeBrightnessRepository.themeBrightnessRepositoryKey,
              any(),
            ),
          ).thenThrow(Exception('oops'));

          final result =
              await themeBrightnessRepository.saveThemeBrightness(sample);

          expect(result, isA<Failure<void>>());

          verify(
            () => sharedPreferencesAsyncService.setString(
              ThemeBrightnessRepository.themeBrightnessRepositoryKey,
              sample.name,
            ),
          ).called(1);

          verifyNever(
            () => sharedPreferencesAsyncService.containsKey(
              ThemeBrightnessRepository.themeBrightnessRepositoryKey,
            ),
          );
          verifyNever(
            () => sharedPreferencesAsyncService.getString(
              ThemeBrightnessRepository.themeBrightnessRepositoryKey,
            ),
          );
        },
      );
    });
  });
}
