import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quotify/features/core/services/notifier.dart';
import 'package:quotify/features/core/services/shared_preferences_async_service.dart';
import 'package:quotify/features/theme/logic/models/primary_colors.dart';
import 'package:quotify/features/theme/repositories/primary_colors_repository.dart';
import 'package:quotify/features/theme/repositories/primary_colors_repository_errors.dart';
import 'package:quotify/features/theme/repositories/primary_colors_repository_impl.dart';
import 'package:quotify/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  const colorsValues = PrimaryColors.values;

  final randomColorSample =
      colorsValues.elementAt(Random().nextInt(colorsValues.length));

  final nonDefaultColors = [...PrimaryColors.values]
    ..removeWhere((color) => color == PrimaryColors.defaultColor);

  final randomNonDefaultColorSample =
      nonDefaultColors.elementAt(Random().nextInt(nonDefaultColors.length));

  late PrimaryColorsRepository colorsRepository;
  late SharedPreferencesAsync sharedPreferencesAsync;

  setUp(() {
    sharedPreferencesAsync = MockSharedPreferencesAsync();
    colorsRepository = PrimaryColorsRepositoryImpl(
      SharedPreferencesAsyncService(sharedPreferencesAsync),
      notifier: notifier,
    );
  });

  group('initialize', () {
    group('when missing key', () {
      setUp(() {
        sharedPreferencesAsync = MockSharedPreferencesAsync();
        colorsRepository = PrimaryColorsRepositoryImpl(
          SharedPreferencesAsyncService(sharedPreferencesAsync),
          notifier: notifier,
        );

        when(
          () => sharedPreferencesAsync
              .containsKey(PrimaryColorsRepository.primaryColorKey),
        ).thenAnswer((_) async => false);
        when(
          () => sharedPreferencesAsync.setString(
            PrimaryColorsRepository.primaryColorKey,
            PrimaryColors.defaultColor.name,
          ),
        ).thenAnswer((_) async {});
      });

      test('set PrimaryColors.defaultColor', () async {
        await (colorsRepository as PrimaryColorsRepositoryImpl).initialize();

        verifyNever(
          () => sharedPreferencesAsync
              .getString(PrimaryColorsRepository.primaryColorKey),
        );
      });
    });

    group('when already have a default value', () {
      setUp(() {
        sharedPreferencesAsync = MockSharedPreferencesAsync();
        colorsRepository = PrimaryColorsRepositoryImpl(
          SharedPreferencesAsyncService(sharedPreferencesAsync),
          notifier: notifier,
        );

        when(
          () => sharedPreferencesAsync
              .containsKey(PrimaryColorsRepository.primaryColorKey),
        ).thenAnswer((_) async => true);
      });
      test('not set PrimaryColors.default', () async {
        await (colorsRepository as PrimaryColorsRepositoryImpl).initialize();

        verifyNever(
          () => sharedPreferencesAsync
              .getString(PrimaryColorsRepository.primaryColorKey),
        );
        verifyNever(
          () => sharedPreferencesAsync.setString(
            PrimaryColorsRepository.primaryColorKey,
            PrimaryColors.defaultColor.name,
          ),
        );
      });
    });
  });

  group('fetchPrimaryColor', () {
    group('without call initialize', () {
      test('should return PrimaryColorsRepositoryErrors.missing', () async {
        verifyNever(() => sharedPreferencesAsync.setString(any(), any()));
        when(
          () => sharedPreferencesAsync
              .getString(PrimaryColorsRepository.primaryColorKey),
        ).thenAnswer((_) async => null);

        final result = await colorsRepository.fetchPrimaryColor();

        expect(result, isA<Failure<PrimaryColors>>());
        expect(
          result.asFailure.failure,
          equals(PrimaryColorsRepositoryErrors.missing),
        );

        verifyNever(() => sharedPreferencesAsync.setString(any(), any()));
      });
    });
    group('after calling initialize', () {
      setUp(() async {
        sharedPreferencesAsync = MockSharedPreferencesAsync();
        colorsRepository = PrimaryColorsRepositoryImpl(
          SharedPreferencesAsyncService(sharedPreferencesAsync),
          notifier: notifier,
        );

        when(
          () => sharedPreferencesAsync
              .containsKey(PrimaryColorsRepository.primaryColorKey),
        ).thenAnswer((_) async => false);

        when(
          () => sharedPreferencesAsync.setString(
            PrimaryColorsRepository.primaryColorKey,
            PrimaryColors.defaultColor.name,
          ),
        ).thenAnswer((_) async {});

        await (colorsRepository as PrimaryColorsRepositoryImpl).initialize();

        verify(
          () => sharedPreferencesAsync.setString(
            PrimaryColorsRepository.primaryColorKey,
            PrimaryColors.defaultColor.name,
          ),
        ).called(1);
      });

      test('should return PrimaryColors.default', () async {
        when(
          () => sharedPreferencesAsync
              .getString(PrimaryColorsRepository.primaryColorKey),
        ).thenAnswer((_) async => PrimaryColors.defaultColor.name);

        final result = await colorsRepository.fetchPrimaryColor();

        expect(result, isA<Ok<PrimaryColors>>());
        expect(result.asOk.value, equals(PrimaryColors.defaultColor));
      });
    });

    group('after setting some value', () {
      setUp(() {
        when(
          () => sharedPreferencesAsync.setString(
            PrimaryColorsRepository.primaryColorKey,
            randomColorSample.name,
          ),
        ).thenAnswer((_) async {});

        when(
          () => sharedPreferencesAsync
              .getString(PrimaryColorsRepository.primaryColorKey),
        ).thenAnswer((_) async => randomColorSample.name);
      });

      test('should return the equivalent PrimaryColors', () async {
        final result = await colorsRepository.fetchPrimaryColor();

        expect(result, isA<Ok<PrimaryColors>>());
        expect(result.asOk.value, equals(randomColorSample));
      });
    });
    group('after some unexpected error', () {
      setUp(() {
        when(
          () => sharedPreferencesAsync
              .getString(PrimaryColorsRepository.primaryColorKey),
        ).thenThrow(Exception('ooops...'));
      });
      test('should return PrimaryColorsRepositoryErrors.unknown', () async {
        final result = await colorsRepository.fetchPrimaryColor();

        expect(result, isA<Failure<PrimaryColors>>());
        expect(
          result.asFailure.failure,
          equals(PrimaryColorsRepositoryErrors.unknown),
        );
      });
    });
  });

  group('savePrimaryColor', () {
    group('without existing value', () {
      setUp(() {
        sharedPreferencesAsync = MockSharedPreferencesAsync();
        colorsRepository = PrimaryColorsRepositoryImpl(
          SharedPreferencesAsyncService(sharedPreferencesAsync),
          notifier: notifier,
        );

        when(
          () => sharedPreferencesAsync
              .getString(PrimaryColorsRepository.primaryColorKey),
        ).thenAnswer((_) async => null);

        when(
          () => sharedPreferencesAsync.setString(
            PrimaryColorsRepository.primaryColorKey,
            randomColorSample.name,
          ),
        ).thenAnswer((_) async {});
      });
      test('should write desired value', () async {
        final result =
            await colorsRepository.savePrimaryColor(randomColorSample);

        expect(result, isA<Ok<bool>>());
        expect(result.asOk.value, isTrue);

        verify(
          () => sharedPreferencesAsync.setString(
            PrimaryColorsRepository.primaryColorKey,
            randomColorSample.name,
          ),
        ).called(1);
      });

      group('and occurs an error when writing', () {
        setUp(() {
          when(
            () => sharedPreferencesAsync.setString(
              PrimaryColorsRepository.primaryColorKey,
              any(),
            ),
          ).thenThrow(Exception('ops!'));
        });
        test(
          'should return a failure with '
          'PrimaryColorsRepositoryErrors.failAtSave',
          () async {
            final result =
                await colorsRepository.savePrimaryColor(randomColorSample);
            expect(result, isA<Failure<bool>>());
            expect(
              result.asFailure.failure,
              equals(PrimaryColorsRepositoryErrors.failAtSaving),
            );
          },
        );
      });
    });
    // group('with existing value', () {
    //   setUp(() async {
    //     sharedPreferencesAsync = MockSharedPreferencesAsync();
    //     colorsRepository = PrimaryColorsRepositoryImpl(
    //       SharedPreferencesAsyncService(sharedPreferencesAsync),
    //       notifier: notifier,
    //     );

    //     when(
    //       () => sharedPreferencesAsync
    //           .containsKey(PrimaryColorsRepository.primaryColorKey),
    //     ).thenAnswer((_) async => false);

    //     when(
    //       () => sharedPreferencesAsync.setString(
    //         PrimaryColorsRepository.primaryColorKey,
    //         any(),
    //       ),
    //     ).thenAnswer((_) async {});

    //     // sets a default value
    //     await (colorsRepository as PrimaryColorsRepositoryImpl).initialize();
    //     when(
    //       () => sharedPreferencesAsync
    //           .getString(PrimaryColorsRepository.primaryColorKey),
    //     ).thenAnswer((_) async => randomColorSample.name);
    //   });
    //   test('should write desired value', () async {
    //     final result =
    //         await colorsRepository.savePrimaryColor(randomColorSample);

    //     expect(result, isA<Ok<bool>>());
    //     expect(result.asOk.value, isTrue);

    //     verify(
    //       () => sharedPreferencesAsync.setString(
    //         PrimaryColorsRepository.primaryColorKey,
    //         randomColorSample.name,
    //       ),
    //     ).called(1);
    //   });

    //   group('and occurs an error when writing', () {
    //     setUp(() {
    //       when(
    //         () => sharedPreferencesAsync.setString(
    //           PrimaryColorsRepository.primaryColorKey,
    //           any(),
    //         ),
    //       ).thenThrow(Exception('ops!'));
    //     });
    //     test(
    //       'should return a failure with '
    //       'PrimaryColorsRepositoryErrors.failAtSave',
    //       () async {
    //         final result =
    //             await colorsRepository.savePrimaryColor(randomColorSample);
    //         expect(result, isA<Failure<bool>>());
    //         expect(
    //           result.asFailure.failure,
    //           equals(PrimaryColorsRepositoryErrors.failAtSaving),
    //         );
    //       },
    //     );
    //   });
    // });
  });
}
