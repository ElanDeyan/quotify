import 'package:meta/meta.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/privacy_data.dart';

/// Defines methods and constants related to privacy data management and
/// password generation.
abstract interface class PrivacyRepository {
  /// This constant is used to represent a key that can be used for access the
  /// encryption key.
  static const dataEncryptionKey = 'encryptionKey';

  /// Represents a key to be used in a data storage to access if user allowed
  /// error reporting.
  static const allowErrorReportingKey = 'allowErrorReporting';

  /// Represents a key to be used in a data storage to access if user accepted
  /// data usage terms.
  static const acceptedDataUsageKey = 'acceptedDataUsage';

  /// Sets default values (if are missing) for:
  /// - encryption key
  /// - allow error reporting
  /// - accepted data usage
  /// - random password
  Future<void> initialize();

  /// Fetches public [PrivacyData] related to user preferences.
  FutureResult<PrivacyData> fetchPrivacyData();

  /// Saves [privacyData] to the data storage.
  FutureResult<void> savePrivacyData(PrivacyData privacyData);

  /// Toggles allow error reporting data in data storage.
  ///
  /// if [Null], the result will just negate the available value. If [bool],
  /// will set the passed [value].
  FutureResult<void> toggleAllowErrorReporting({bool? value});

  /// Toggles accepted data usage in data storage.
  ///
  /// if [Null], the result will just negate the available value. If [bool],
  /// will set the passed [value].
  FutureResult<void> toggleAcceptedAppDataUsage({bool? value});

  /// Generates a random and secure password with 16-32 chars.
  @visibleForTesting
  String generateRandomSecurePassword();

  FutureResult<void> setEncryptionPassword();

  FutureResult<String> fetchEncryptionPassword();
}
