import 'privacy_repository.dart';

/// [Exception]s related to [PrivacyRepository].
enum PrivacyRepositoryErrors implements Exception {
  /// When some of the keys are missing.
  missingSomeKey,

  /// Used when the stored value cannot be converted to [bool].
  invalidBooleanString;
}
