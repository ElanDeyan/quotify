import 'dart:math';

import 'package:flutter_secure_storage_service/flutter_secure_storage_service.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/privacy_data.dart';
import 'privacy_data_repository_errors.dart';
import 'privacy_repository.dart';

/// Implementation of [PrivacyRepository].
final class PrivacyRepositoryImpl implements PrivacyRepository {
  /// Implementation of [PrivacyRepository].
  const PrivacyRepositoryImpl(this._secureStorageService);

  final FlutterSecureStorageService _secureStorageService;

  @override
  FutureResult<PrivacyData> fetchPrivacyData() async {
    final acceptedDataUsageString = await _secureStorageService
        .read(PrivacyRepository.acceptedDataUsageKey);
    final allowErrorReportingString = await _secureStorageService
        .read(PrivacyRepository.allowErrorReportingKey);
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

    final requiredChars = [
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
        (_) => allowedChars
            .codeUnitAt(Random.secure().nextInt(allowedChars.length)),
      ),
    );

    final allChars = (requiredChars + passwordChars).split('')
      ..shuffle(Random.secure());

    final password = allChars.join();

    assert(
      password.length >= 16 && password.length <= 32,
      'Should be within 16 and 32',
    );
    return password;
  }

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  FutureResult<void> savePrivacyData(PrivacyData privacyData) {
    // TODO: implement savePrivacyData
    throw UnimplementedError();
  }

  @override
  FutureResult<void> toggleAcceptedAppDataUsage({bool? value}) {
    // TODO: implement toggleAcceptedAppDataUsage
    throw UnimplementedError();
  }

  @override
  FutureResult<void> toggleAllowErrorReporting({bool? value}) {
    // TODO: implement toggleAllowErrorReporting
    throw UnimplementedError();
  }

  @override
  FutureResult<String> fetchEncryptionPassword() {
    // TODO: implement fetchEncryptionPassword
    throw UnimplementedError();
  }

  @override
  FutureResult<void> setEncryptionPassword() {
    // TODO: implement setEncryptionPassword
    throw UnimplementedError();
  }
}
