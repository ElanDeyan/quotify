import 'package:flutter_secure_storage_service/flutter_secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_strength/password_strength.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/repositories/privacy_data_repository_errors.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:privacy_repository/repositories/privacy_repository_impl.dart';
import 'package:quotify_utils/quotify_utils.dart';

final class MockFlutterSecureStorageService extends Mock
    implements FlutterSecureStorageService {}

void main() {
  late PrivacyRepository privacyRepository;
  late FlutterSecureStorageService secureStorageService;

  setUp(() {
    secureStorageService = MockFlutterSecureStorageService();
    privacyRepository = PrivacyRepositoryImpl(secureStorageService);
  });

  group('generateRandomSecurePassword', () {
    test('should have 16-32 length', () {
      expect(
        privacyRepository.generateRandomSecurePassword().length,
        allOf([
          greaterThanOrEqualTo(16),
          lessThanOrEqualTo(32),
        ]),
      );
    });

    test('has at least 1 lower case letter', () {
      expect(
        privacyRepository
            .generateRandomSecurePassword()
            .contains(RegExp('[a-z]+')),
        isTrue,
      );
    });

    test('has at least 1 upper case letter', () {
      expect(
        privacyRepository
            .generateRandomSecurePassword()
            .contains(RegExp('[A-Z]+')),
        isTrue,
      );
    });

    test('has at least 1 digit', () {
      expect(
        privacyRepository
            .generateRandomSecurePassword()
            .contains(RegExp('[0-9]+')),
        isTrue,
      );
    });

    test('has at least 1 symbol', () {
      expect(
        privacyRepository
            .generateRandomSecurePassword()
            .contains(RegExp(r'[!?@#$%^&*()\[\]{}/\\~"]+')),
        isTrue,
      );
    });

    test('called two times should be different', () {
      final first = privacyRepository.generateRandomSecurePassword();
      final second = privacyRepository.generateRandomSecurePassword();
      expect(first, isNot(second));
    });

    test(
      'should have >= 0.9 of strength',
      () {
        for (var i = 0; i < 50; i++) {
          final passwordStrength = estimatePasswordStrength(
            privacyRepository.generateRandomSecurePassword(),
          );

          expect(
            passwordStrength,
            greaterThanOrEqualTo(0.9),
          );
        }
      },
    );
  });

  group('fetchPrivacyData', () {
    group('with both values missing', () {
      setUp(() {
        when(
          () =>
              secureStorageService.read(PrivacyRepository.acceptedDataUsageKey),
        ).thenAnswer((_) async => null);
        when(
          () => secureStorageService
              .read(PrivacyRepository.allowErrorReportingKey),
        ).thenAnswer((_) async => null);
      });

      test(
        'should return a Failure with PrivacyDataRepositoryErrors.missing',
        () async {
          final result = await privacyRepository.fetchPrivacyData();

          expect(result, isA<Failure<PrivacyData>>());
          expect(
            result.asFailure.failure,
            equals(PrivacyRepositoryErrors.missingSomeKey),
          );

          verify(
            () => secureStorageService
                .read(PrivacyRepository.acceptedDataUsageKey),
          ).called(1);
          verify(
            () => secureStorageService
                .read(PrivacyRepository.allowErrorReportingKey),
          ).called(1);
        },
      );
    });
    group('with only of two is missing', () {
      setUp(() {
        when(
          () =>
              secureStorageService.read(PrivacyRepository.acceptedDataUsageKey),
        ).thenAnswer((_) async => 'true');
        when(
          () => secureStorageService
              .read(PrivacyRepository.allowErrorReportingKey),
        ).thenAnswer((_) async => null);
      });
      test(
        'should return a Failure with PrivacyDataRepositoryErrors.missing',
        () async {
          final result = await privacyRepository.fetchPrivacyData();

          expect(result, isA<Failure<PrivacyData>>());
          expect(
            result.asFailure.failure,
            equals(PrivacyRepositoryErrors.missingSomeKey),
          );

          verify(
            () => secureStorageService
                .read(PrivacyRepository.acceptedDataUsageKey),
          ).called(1);
          verify(
            () => secureStorageService
                .read(PrivacyRepository.allowErrorReportingKey),
          ).called(1);
        },
      );
    });

    group('with both values present', () {
      group('but one or both is not a valid boolean string', () {
        setUp(() {
          when(
            () => secureStorageService
                .read(PrivacyRepository.acceptedDataUsageKey),
          ).thenAnswer((_) async => true.toString());
          when(
            () => secureStorageService
                .read(PrivacyRepository.allowErrorReportingKey),
          ).thenAnswer((_) async => 'hello!');
        });
        test(
          'should return a Failure with PrivacyRepositoryErrors.invalidBooleanString',
          () async {
            final result = await privacyRepository.fetchPrivacyData();

            expect(result, isA<Failure<PrivacyData>>());
            expect(
              result.asFailure.failure,
              equals(PrivacyRepositoryErrors.invalidBooleanString),
            );

            verify(
              () => secureStorageService
                  .read(PrivacyRepository.acceptedDataUsageKey),
            ).called(1);
            verify(
              () => secureStorageService
                  .read(PrivacyRepository.allowErrorReportingKey),
            ).called(1);
          },
        );
      });
    });

    group('with both values present and valid', () {
      const allowedErrorReporting = true;
      const acceptedDataUsage = false;
      const expectedPrivacyData = PrivacyData(
        allowErrorReporting: allowedErrorReporting,
        // ignore: avoid_redundant_argument_values
        acceptedDataUsage: acceptedDataUsage,
      );
      setUp(() {
        when(
          () =>
              secureStorageService.read(PrivacyRepository.acceptedDataUsageKey),
        ).thenAnswer((_) async => acceptedDataUsage.toString());
        when(
          () => secureStorageService
              .read(PrivacyRepository.allowErrorReportingKey),
        ).thenAnswer((_) async => allowedErrorReporting.toString());
      });

      test('should return Ok with the PrivacyData', () async {
        final result = await privacyRepository.fetchPrivacyData();

        expect(result, isA<Ok<PrivacyData>>());
        expect(
          result.asOk.value,
          equals(expectedPrivacyData),
        );

        verify(
          () =>
              secureStorageService.read(PrivacyRepository.acceptedDataUsageKey),
        ).called(1);
        verify(
          () => secureStorageService
              .read(PrivacyRepository.allowErrorReportingKey),
        ).called(1);
      });
    });
  });
}
