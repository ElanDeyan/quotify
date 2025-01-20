import '../logic/models/privacy_data_errors.dart';
import 'privacy_repository.dart';

/// [Exception]s related to [PrivacyRepository].
enum PrivacyRepositoryErrors implements PrivacyDataErrors {
  /// When some of the keys are missing.
  missingSomeKey,

  /// Used when the stored value cannot be converted to [bool].
  invalidBooleanString,

  /// Used when the stored value cannot be converted to [String].
  invalidEncryptionPassword,

  /// Used when the stored value cannot be stored.
  failAtWriting,
}
