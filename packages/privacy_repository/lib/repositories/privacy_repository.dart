import 'package:meta/meta.dart';
import 'package:quotify_utils/result.dart';

import '../logic/models/privacy_data.dart';
import 'privacy_data_entry.dart';
import 'privacy_data_repository_errors.dart';

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
  /// - encryption password
  /// - allow error reporting
  /// - accepted data usage
  FutureResult<(), Iterable<PrivacyRepositoryErrors>> initialize();

  /// Sets default value (if are missing) for encryption password
  @visibleForTesting
  FutureResult<(), PrivacyRepositoryErrors> setEncryptionPasswordIfMissing();

  /// Sets default values (if are missing) for privacy data.
  @visibleForTesting
  FutureResult<(), PrivacyRepositoryErrors> setPrivacyDataIfMissing();

  /// Fetches public [PrivacyData] related to user preferences.
  FutureResult<PrivacyData, PrivacyRepositoryErrors> fetchPrivacyData();

  /// Saves [privacyDataEntry] to the data storage.
  FutureResult<(), PrivacyRepositoryErrors> savePrivacyData(
    PrivacyDataEntry privacyDataEntry,
  );

  /// Generates a random and secure password with 16-32 chars.
  @visibleForTesting
  String generateRandomSecurePassword();

  /// Sets the encryption password to the data storage by
  /// calling [generateRandomSecurePassword].
  FutureResult<(), Object> setEncryptionPassword();

  /// Fetches the encryption password from the data storage.
  FutureResult<String, PrivacyRepositoryErrors> fetchEncryptionPassword();

  /// Helper to ensure the generated password is valid.
  @visibleForTesting
  bool isEncryptionPasswordValid(String password);
}
