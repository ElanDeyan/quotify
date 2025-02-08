import 'package:flutter_secure_storage_service/flutter_secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_strength/password_strength.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/repositories/privacy_data_entry.dart';
import 'package:privacy_repository/repositories/privacy_data_repository_errors.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:privacy_repository/repositories/privacy_repository_impl.dart';
import 'package:quotify_utils/result.dart';

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

          expect(result, isA<Failure<PrivacyData, PrivacyRepositoryErrors>>());
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

          expect(result, isA<Failure<PrivacyData, PrivacyRepositoryErrors>>());
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
          'should return a Failure with '
          'PrivacyRepositoryErrors.invalidBooleanString',
          () async {
            final result = await privacyRepository.fetchPrivacyData();

            expect(
              result,
              isA<Failure<PrivacyData, PrivacyRepositoryErrors>>(),
            );
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

        expect(result, isA<Ok<PrivacyData, PrivacyRepositoryErrors>>());
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

  group('savePrivacyData', () {
    group(
        'without any (or both) data present and entry has both null parameters',
        () {
      setUp(() {
        when(
          () => secureStorageService.containsKey(any()),
        ).thenAnswer((_) async => false);
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.acceptedDataUsageKey),
        ).called(1);
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.allowErrorReportingKey),
        ).called(1);

        verifyNever(() => secureStorageService.read(any()));
        verifyNever(() => secureStorageService.write(any(), any()));
      });
      test(
        'should return Failure with PrivacyRepositoryErrors.missing',
        () async {
          await privacyRepository.savePrivacyData(const PrivacyDataEntry());
        },
      );
    });
    group('with data present', () {
      setUp(() {
        when(() => secureStorageService.containsKey(any()))
            .thenAnswer((_) async => true);
        when(() => secureStorageService.write(any(), any()))
            .thenAnswer((_) async {});
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.acceptedDataUsageKey),
        ).called(1);
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.allowErrorReportingKey),
        ).called(1);
        verify(() => secureStorageService.write(any(), any()))
            .called(inInclusiveRange(1, 2));
      });

      test(
        'and one parameter is null should only '
        'write the non-null (allowErrorReporting)',
        () async {
          const sample = PrivacyDataEntry(allowErrorReporting: true);

          final result = await privacyRepository.savePrivacyData(sample);

          expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
        },
      );

      test(
        'and one parameter is null should only '
        'write the non-null (acceptedDataUsage)',
        () async {
          const sample = PrivacyDataEntry(acceptedDataUsage: true);

          final result = await privacyRepository.savePrivacyData(sample);

          expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
        },
      );
      test(
        'and both parameters are not null should write both',
        () async {
          const sample = PrivacyDataEntry(
            acceptedDataUsage: true,
            allowErrorReporting: false,
          );

          final result = await privacyRepository.savePrivacyData(sample);

          expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
        },
      );
    });
  });

  group('isEncryptionPasswordValid', () {
    group('with invalid passwords', () {
      final sampleLowerCasePassword = 'a' * 16;
      final sampleUpperCasePassword = 'P' * 16;
      final sampleDigitPassword = '0' * 16;
      final sampleSymbolPassword = '!' * 16;
      final sampleShortPassword = 'Lk0[' * 2;
      final sampleLongPassword = 'Rf0!' * 9;
      final sampleLowerUpperCasePassword = 'nB' * 8;
      final sampleLowerDigitPassword = 's0' * 8;
      final sampleLowerSymbolPassword = 'h[' * 8;
      final sampleUpperDigitPassword = 'D0' * 8;
      final sampleUpperSymbolPassword = 'U%' * 8;
      final sampleDigitSymbolPassword = '0=' * 8;
      final sampleLowerUpperDigitPassword = 'wZ0' * 6;
      final sampleLowerUpperSymbolPassword = 'qX-' * 6;
      final sampleLowerDigitSymbolPassword = 'y0]' * 6;
      final sampleUpperDigitSymbolPassword = 'E0+' * 6;

      final allInvalidPasswords = [
        sampleLowerCasePassword,
        sampleUpperCasePassword,
        sampleDigitPassword,
        sampleSymbolPassword,
        sampleShortPassword,
        sampleLongPassword,
        sampleLowerUpperCasePassword,
        sampleLowerDigitPassword,
        sampleLowerSymbolPassword,
        sampleUpperDigitPassword,
        sampleUpperSymbolPassword,
        sampleDigitSymbolPassword,
        sampleLowerUpperDigitPassword,
        sampleLowerUpperSymbolPassword,
        sampleLowerDigitSymbolPassword,
        sampleUpperDigitSymbolPassword,
      ];

      test('should return false', () {
        for (final password in allInvalidPasswords) {
          expect(
            privacyRepository.isEncryptionPasswordValid(password),
            isFalse,
          );
        }
      });
    });

    group('with valid passwords', () {
      final sampleValidPasswords = [
        r'A2e$' * 4,
        'B3r@' * 4,
        'C4t#' * 4,
        'D5y%' * 4,
        'E6u[' * 4,
        'F7i&' * 4,
        'G8o*' * 4,
        'H9p(' * 4,
        'I0q)' * 4,
        'J1w-' * 4,
      ];

      test('should return true', () {
        for (final password in sampleValidPasswords) {
          expect(
            privacyRepository.isEncryptionPasswordValid(password),
            isTrue,
          );
        }
      });
    });
  });

  group('fetchEncryptionPassword', () {
    group('with no key present', () {
      setUp(() {
        when(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        ).thenAnswer((_) async => false);
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        ).called(1);
        verifyNever(() => secureStorageService.read(any()));
      });

      test('should return Failure with PrivacyRepository.missingKey', () async {
        final result = await privacyRepository.fetchEncryptionPassword();

        expect(result, isA<Failure<String, PrivacyRepositoryErrors>>());
        expect(
          result.asFailure.failure,
          equals(PrivacyRepositoryErrors.missingSomeKey),
        );
      });
    });

    group('with key present, but invalid,', () {
      setUp(() {
        when(() => secureStorageService.containsKey(any()))
            .thenAnswer((_) async => true);
        when(
          () => secureStorageService.read(PrivacyRepository.dataEncryptionKey),
        ).thenAnswer((_) async => 'password');
      });
      test(' should return Failure with invalidEncryptionPassword', () async {
        final result = await privacyRepository.fetchEncryptionPassword();

        expect(result, isA<Failure<String, PrivacyRepositoryErrors>>());
        expect(
          result.asFailure.failure,
          equals(PrivacyRepositoryErrors.invalidEncryptionPassword),
        );
      });
    });

    group('with key present, but valid', () {
      const samplePassword = 'Password123!@Ee6';
      setUp(() {
        when(() => secureStorageService.containsKey(any()))
            .thenAnswer((_) async => true);
        when(
          () => secureStorageService.read(PrivacyRepository.dataEncryptionKey),
        ).thenAnswer((_) async => samplePassword);
      });

      test('should return Ok with the password', () async {
        final result = await privacyRepository.fetchEncryptionPassword();

        expect(result, isA<Ok<String, PrivacyRepositoryErrors>>());
        expect(
          result.asOk.value,
          equals(samplePassword),
        );
      });
    });
  });

  group('setEncryptionPassword', () {
    group('with no errors on write', () {
      setUp(() {
        when(() => secureStorageService.write(any(), any()))
            .thenAnswer((_) async {});
      });

      tearDown(() {
        verify(() => secureStorageService.write(any(), any())).called(1);
        verifyNever(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        );
        verifyNever(
          () => secureStorageService.read(PrivacyRepository.dataEncryptionKey),
        );
      });

      test('should return ok', () async {
        final result = await privacyRepository.setEncryptionPassword();

        expect(result, isA<Ok<(), Object>>());
      });
    });

    group('with errors on write', () {
      setUp(() {
        when(() => secureStorageService.write(any(), any()))
            .thenThrow(Exception());
      });

      tearDown(() {
        verify(() => secureStorageService.write(any(), any())).called(1);
        verifyNever(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        );
        verifyNever(
          () => secureStorageService.read(PrivacyRepository.dataEncryptionKey),
        );
      });

      test('should return failure', () async {
        final result = await privacyRepository.setEncryptionPassword();

        expect(result, isA<Failure<(), Object>>());
      });
    });
  });

  group('setEncryptionPasswordIfMissing', () {
    group('with no key present', () {
      setUp(() {
        when(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        ).thenAnswer((_) async => false);
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        ).called(1);
        verify(() => secureStorageService.write(any(), any())).called(1);
        verifyNever(() => secureStorageService.read(any()));
      });

      test('should call secureStorageService.write once', () async {
        final result = await privacyRepository.setEncryptionPasswordIfMissing();
        expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
      });
    });

    group('with key present', () {
      setUp(() {
        when(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        ).thenAnswer((_) async => true);
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.dataEncryptionKey),
        ).called(1);
        verifyNever(() => secureStorageService.read(any()));
        verifyNever(() => secureStorageService.write(any(), any()));
      });

      test('should not call secureStorageService.write', () async {
        final result = await privacyRepository.setEncryptionPasswordIfMissing();
        expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
      });
    });
  });

  group('setPrivacyDataIfMissing', () {
    group('without one of keys present', () {
      setUp(() {
        when(
          () => secureStorageService
              .containsKey(PrivacyRepository.acceptedDataUsageKey),
        ).thenAnswer((_) async => false);
        when(
          () => secureStorageService
              .containsKey(PrivacyRepository.allowErrorReportingKey),
        ).thenAnswer((_) async => true);
        when(() => secureStorageService.write(any(), any()))
            .thenAnswer((_) async {});
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.acceptedDataUsageKey),
        ).called(2);
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.allowErrorReportingKey),
        ).called(2);
        verify(
          () => secureStorageService.write(
            PrivacyRepository.acceptedDataUsageKey,
            const PrivacyData.initial().acceptedDataUsage.toString(),
          ),
        ).called(1);
      });

      test('should write only in the missing key', () async {
        final result = await privacyRepository.setPrivacyDataIfMissing();
        expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
      });
    });

    group('without any keys present', () {
      setUp(() {
        when(
          () => secureStorageService.containsKey(any()),
        ).thenAnswer((_) async => false);
        when(() => secureStorageService.write(any(), any()))
            .thenAnswer((_) async {});
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.acceptedDataUsageKey),
        ).called(2);
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.allowErrorReportingKey),
        ).called(2);
        verify(
          () => secureStorageService.write(
            PrivacyRepository.acceptedDataUsageKey,
            const PrivacyData.initial().acceptedDataUsage.toString(),
          ),
        ).called(1);
        verify(
          () => secureStorageService.write(
            PrivacyRepository.allowErrorReportingKey,
            const PrivacyData.initial().allowErrorReporting.toString(),
          ),
        ).called(1);
      });

      test('should write both keys', () async {
        final result = await privacyRepository.setPrivacyDataIfMissing();
        expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
      });
    });

    group('with both keys present', () {
      setUp(() {
        when(
          () => secureStorageService.containsKey(any()),
        ).thenAnswer((_) async => true);
        when(() => secureStorageService.write(any(), any()))
            .thenAnswer((_) async {});
      });

      tearDown(() {
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.acceptedDataUsageKey),
        ).called(2);
        verify(
          () => secureStorageService
              .containsKey(PrivacyRepository.allowErrorReportingKey),
        ).called(2);
        verifyNever(
          () => secureStorageService.write(
            PrivacyRepository.acceptedDataUsageKey,
            const PrivacyData.initial().acceptedDataUsage.toString(),
          ),
        );
        verifyNever(
          () => secureStorageService.write(
            PrivacyRepository.allowErrorReportingKey,
            const PrivacyData.initial().allowErrorReporting.toString(),
          ),
        );
      });

      test('should not write', () async {
        final result = await privacyRepository.setPrivacyDataIfMissing();
        expect(result, isA<Ok<(), PrivacyRepositoryErrors>>());
      });
    });
  });
}
