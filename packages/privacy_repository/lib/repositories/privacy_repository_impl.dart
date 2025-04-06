import 'dart:math';

import 'package:flutter_secure_storage_service/flutter_secure_storage_service.dart';
import 'package:quotify_utils/result.dart';

import '../logic/models/privacy_data.dart';
import 'privacy_data_entry.dart';
import 'privacy_data_repository_errors.dart';
import 'privacy_repository.dart';

/// Implementation of [PrivacyRepository].
final class PrivacyRepositoryImpl implements PrivacyRepository {
  /// Implementation of [PrivacyRepository].
  const PrivacyRepositoryImpl(this._secureStorageService);

  final FlutterSecureStorageService _secureStorageService;

  @override
  FutureResult<PrivacyData, PrivacyRepositoryErrors> fetchPrivacyData() async {
    final acceptedDataUsageString = await _secureStorageService.read(
      PrivacyRepository.acceptedDataUsageKey,
    );
    final allowErrorReportingString = await _secureStorageService.read(
      PrivacyRepository.allowErrorReportingKey,
    );
    if (acceptedDataUsageString == null || allowErrorReportingString == null) {
      return Result.failure(
        PrivacyRepositoryErrors.missingSomeKey,
        StackTrace.current,
      );
    }

    final acceptedDataUsage = bool.tryParse(acceptedDataUsageString);
    final allowErrorReporting = bool.tryParse(allowErrorReportingString);
    if (acceptedDataUsage == null || allowErrorReporting == null) {
      return Result.failure(
        PrivacyRepositoryErrors.invalidBooleanString,
        StackTrace.current,
      );
    }

    return Result.ok(
      PrivacyData(
        acceptedDataUsage: acceptedDataUsage,
        allowErrorReporting: allowErrorReporting,
      ),
    );
  }

  @override
  String generateRandomSecurePassword() {
    final passwordLength = Random.secure().nextInt(16) + 16;
    const lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    final upperCaseLetters = lowerCaseLetters.toUpperCase();
    const numbers = '0123456789';
    const specialChars = r'!@#$%&*(){}[]\|?/+=_-';

    final requiredChars =
        [
          lowerCaseLetters[Random.secure().nextInt(lowerCaseLetters.length)],
          upperCaseLetters[Random.secure().nextInt(upperCaseLetters.length)],
          numbers[Random.secure().nextInt(numbers.length)],
          specialChars[Random.secure().nextInt(specialChars.length)],
        ].join();

    final allowedChars =
        lowerCaseLetters + upperCaseLetters + numbers + specialChars;

    final passwordChars = String.fromCharCodes(
      List.generate(
        passwordLength - requiredChars.length,
        (_) => allowedChars.codeUnitAt(
          Random.secure().nextInt(allowedChars.length),
        ),
      ),
    );

    final allChars = (requiredChars + passwordChars).split('')
      ..shuffle(Random.secure());

    final password = allChars.join();

    assert(
      password.length >= 16 && password.length <= 32,
      'Should be within 16 and 32',
    );
    assert(
      password.contains(RegExp('[a-z]')) &&
          password.contains(RegExp('[A-Z]')) &&
          password.contains(RegExp('[0-9]')) &&
          password.contains(RegExp(r'[!@#$%&*(){}[\]\|?/+=_-]')),
      'Should contain at least one of each: lowercase, uppercase, number, '
      'special char',
    );

    return password;
  }

  @override
  FutureResult<(), Iterable<PrivacyRepositoryErrors>> initialize() =>
      Result.guardAsync(() async {
        final results = await Future.wait([
          setPrivacyDataIfMissing(),
          setEncryptionPasswordIfMissing(),
        ]);
        if (results.anyFailure()) {
          throw PrivacyRepositoryErrors.failAtWriting;
        }

        return ();
      });

  @override
  FutureResult<(), PrivacyRepositoryErrors>
  setEncryptionPasswordIfMissing() async {
    if (!(await _secureStorageService.containsKey(
      PrivacyRepository.dataEncryptionKey,
    ))) {
      return (await Result.guardAsync(setEncryptionPassword)).mapAsync(
        (value) async => (),
        failureMapper: (_) => PrivacyRepositoryErrors.failAtWriting,
      );
    }

    return const Result.ok(());
  }

  @override
  FutureResult<(), PrivacyRepositoryErrors> setPrivacyDataIfMissing() async {
    final PrivacyData(
      acceptedDataUsage: defaultAcceptedDataUsage,
      allowErrorReporting: defaultAllowErrorReporting,
    ) = const PrivacyData.initial();

    final allowErrorReportingEntry =
        await _secureStorageService.containsKey(
              PrivacyRepository.allowErrorReportingKey,
            )
            ? null
            : defaultAllowErrorReporting;

    final acceptedDataUsageEntry =
        await _secureStorageService.containsKey(
              PrivacyRepository.acceptedDataUsageKey,
            )
            ? null
            : defaultAcceptedDataUsage;

    return Result.guardAsync(() async {
      await savePrivacyData(
        PrivacyDataEntry(
          allowErrorReporting: allowErrorReportingEntry,
          acceptedDataUsage: acceptedDataUsageEntry,
        ),
      );

      return ();
    });
  }

  @override
  FutureResult<(), PrivacyRepositoryErrors> savePrivacyData(
    PrivacyDataEntry privacyDataEntry,
  ) async {
    final hasAllowErrorReportingKey = await _secureStorageService.containsKey(
      PrivacyRepository.allowErrorReportingKey,
    );
    final hasAcceptedDataUsageKey = await _secureStorageService.containsKey(
      PrivacyRepository.acceptedDataUsageKey,
    );

    final notHasAllowErrorReportingKeyAndNullValuePassed =
        !hasAllowErrorReportingKey &&
        privacyDataEntry.allowErrorReporting == null;

    final notHasAcceptedDataUsageKeyAndNullValuePassed =
        !hasAcceptedDataUsageKey && privacyDataEntry.acceptedDataUsage == null;

    if (notHasAllowErrorReportingKeyAndNullValuePassed ||
        notHasAcceptedDataUsageKeyAndNullValuePassed) {
      return Result.failure(
        PrivacyRepositoryErrors.missingSomeKey,
        StackTrace.current,
      );
    }

    if (privacyDataEntry.allowErrorReporting != null) {
      await _secureStorageService.write(
        PrivacyRepository.allowErrorReportingKey,
        privacyDataEntry.allowErrorReporting.toString(),
      );
    }

    if (privacyDataEntry.acceptedDataUsage != null) {
      await _secureStorageService.write(
        PrivacyRepository.acceptedDataUsageKey,
        privacyDataEntry.acceptedDataUsage.toString(),
      );
    }

    return const Result.ok(());
  }

  @override
  FutureResult<String, PrivacyRepositoryErrors>
  fetchEncryptionPassword() async {
    if (!(await _secureStorageService.containsKey(
      PrivacyRepository.dataEncryptionKey,
    ))) {
      return Result.failure(
        PrivacyRepositoryErrors.missingSomeKey,
        StackTrace.current,
      );
    }

    final encryptionKey = await _secureStorageService.read(
      PrivacyRepository.dataEncryptionKey,
    );

    if (encryptionKey == null) {
      return Result.failure(
        PrivacyRepositoryErrors.missingSomeKey,
        StackTrace.current,
      );
    }

    if (!isEncryptionPasswordValid(encryptionKey)) {
      return Result.failure(
        PrivacyRepositoryErrors.invalidEncryptionPassword,
        StackTrace.current,
      );
    }

    return Result.ok(
      (await _secureStorageService.read(PrivacyRepository.dataEncryptionKey))!,
    );
  }

  @override
  bool isEncryptionPasswordValid(String password) {
    if (password.length < 16 || password.length > 32) {
      return false;
    }

    if (password.contains(RegExp('[a-z]')) &&
        password.contains(RegExp('[A-Z]')) &&
        password.contains(RegExp('[0-9]')) &&
        password.contains(RegExp(r'[!@#$%&*(){}[\]\|?/+=_-]'))) {
      return true;
    }

    return false;
  }

  @override
  FutureResult<(), Object> setEncryptionPassword() {
    final password = generateRandomSecurePassword();

    return Result.guardAsync(() async {
      await _secureStorageService.write(
        PrivacyRepository.dataEncryptionKey,
        password,
      );
      return ();
    });
  }
}
