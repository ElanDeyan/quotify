import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:primary_colors_repository/models/primary_colors_errors.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository_errors.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository_impl.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:shared_preferences_service/shared_preferences_async_service.dart';
import 'package:shared_preferences_service_test/mock_shared_preferences_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferencesAsyncService sharedPreferencesAsyncService;
  late PrimaryColorsRepository primaryColorsRepository;
  setUp(() {
    sharedPreferencesAsyncService =
        SharedPreferencesAsyncService(MockSharedPreferencesAsync());
    primaryColorsRepository = PrimaryColorsRepositoryImpl(
      sharedPreferencesAsyncService,
    );
  });

  group('initialize', () {
    test('when does not have an existent value, sets defaultColor', () async {
      when(
        () => sharedPreferencesAsyncService
            .containsKey(PrimaryColorsRepository.primaryColorKey),
      ).thenAnswer((_) async => false);
      when(
        () => sharedPreferencesAsyncService.setString(
          PrimaryColorsRepository.primaryColorKey,
          PrimaryColors.defaultColor.name,
        ),
      ).thenAnswer((_) async {});

      await primaryColorsRepository.initialize();

      verify(
        () => sharedPreferencesAsyncService
            .containsKey(PrimaryColorsRepository.primaryColorKey),
      ).called(1);

      verify(
        () => sharedPreferencesAsyncService.setString(
          PrimaryColorsRepository.primaryColorKey,
          PrimaryColors.defaultColor.name,
        ),
      ).called(1);
    });

    test('when have an existent value, not changes', () async {
      when(
        () => sharedPreferencesAsyncService
            .containsKey(PrimaryColorsRepository.primaryColorKey),
      ).thenAnswer((_) async => true);

      await primaryColorsRepository.initialize();

      verify(
        () => sharedPreferencesAsyncService
            .containsKey(PrimaryColorsRepository.primaryColorKey),
      ).called(1);

      verifyNever(
        () => sharedPreferencesAsyncService.setString(
          PrimaryColorsRepository.primaryColorKey,
          PrimaryColors.defaultColor.name,
        ),
      );
    });
  });

  group('fetchPrimaryColor', () {
    tearDown(() {
      verifyNever(
        () => sharedPreferencesAsyncService.setString(
          PrimaryColorsRepository.primaryColorKey,
          any(),
        ),
      );
    });
    test(
      'without an already existent value should return a '
      'Failure with PrimaryColorRepositoryErrors.missing',
      () async {
        when(
          () => sharedPreferencesAsyncService.containsKey(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).thenAnswer((_) async => false);

        final result = await primaryColorsRepository.fetchPrimaryColor();

        expect(result, isA<Failure<PrimaryColors>>());
        expect(
          result.asFailure.failure,
          equals(PrimaryColorsRepositoryErrors.missing),
        );

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).called(1);

        verifyNever(
          () => sharedPreferencesAsyncService.getString(
            PrimaryColorsRepository.primaryColorKey,
          ),
        );
      },
    );

    test(
      'with an existent value, should return Ok with the PrimaryColor',
      () async {
        const sample = PrimaryColors.coolBlush;

        when(
          () => sharedPreferencesAsyncService.containsKey(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).thenAnswer((_) async => true);
        when(
          () => sharedPreferencesAsyncService.getString(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).thenAnswer((_) async => sample.name);

        final result = await primaryColorsRepository.fetchPrimaryColor();

        expect(result, isA<Ok<PrimaryColors>>());
        expect(result.asOk.value, equals(sample));

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).called(1);
        verify(
          () => sharedPreferencesAsyncService.getString(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).called(1);
      },
    );
    test(
      'with an invalid existent value, should return Failure '
      'with the PrimaryColorsErrors.invalidStringRepresentation',
      () async {
        final sample = faker.lorem.word();

        assert(
          !PrimaryColors.values.map((color) => color.name).contains(sample),
          'Should be an invalid name for this test',
        );

        when(
          () => sharedPreferencesAsyncService.containsKey(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).thenAnswer((_) async => true);
        when(
          () => sharedPreferencesAsyncService.getString(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).thenAnswer((_) async => sample);

        final result = await primaryColorsRepository.fetchPrimaryColor();

        expect(result, isA<Failure<PrimaryColors>>());
        expect(
          result.asFailure.failure,
          equals(PrimaryColorsErrors.invalidStringRepresentation),
        );

        verify(
          () => sharedPreferencesAsyncService.containsKey(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).called(1);
        verify(
          () => sharedPreferencesAsyncService.getString(
            PrimaryColorsRepository.primaryColorKey,
          ),
        ).called(1);
      },
    );
  });

  group('saveThemeBrightness', () {
    group('whatever it has an already value or not', () {
      test('should write the desired value', () async {
        const sample = PrimaryColors.icyLilac;
        when(
          () => sharedPreferencesAsyncService.setString(
            PrimaryColorsRepository.primaryColorKey,
            sample.name,
          ),
        ).thenAnswer((_) async {});

        final result = await primaryColorsRepository.savePrimaryColor(sample);

        expect(result, isA<Ok<void>>());

        verify(
          () => sharedPreferencesAsyncService.setString(
            PrimaryColorsRepository.primaryColorKey,
            sample.name,
          ),
        ).called(1);

        verifyNever(
          () => sharedPreferencesAsyncService.containsKey(
            PrimaryColorsRepository.primaryColorKey,
          ),
        );
        verifyNever(
          () => sharedPreferencesAsyncService.getString(
            PrimaryColorsRepository.primaryColorKey,
          ),
        );
      });
    });
    group('if something went wrong on saving', () {
      test(
        'should return a Failure with '
        'PrimaryColorsRepositoryErrors.failAtSaving',
        () async {
          const sample = PrimaryColors.powderBlue;

          when(
            () => sharedPreferencesAsyncService.setString(
              PrimaryColorsRepository.primaryColorKey,
              any(),
            ),
          ).thenThrow(Exception('oops'));

          final result = await primaryColorsRepository.savePrimaryColor(sample);

          expect(result, isA<Failure<void>>());

          verify(
            () => sharedPreferencesAsyncService.setString(
              PrimaryColorsRepository.primaryColorKey,
              sample.name,
            ),
          ).called(1);

          verifyNever(
            () => sharedPreferencesAsyncService.containsKey(
              PrimaryColorsRepository.primaryColorKey,
            ),
          );
          verifyNever(
            () => sharedPreferencesAsyncService.getString(
              PrimaryColorsRepository.primaryColorKey,
            ),
          );
        },
      );
    });
  });
}
