import '../../../utils/future_result.dart';
import '../logic/models/privacy_data.dart';

abstract interface class PrivacyRepository {
  static const dataEncryptionKey = 'encryptionKey';

  static const allowErrorReportingKey = 'allowErrorReporting';

  static const acceptedDataUsage = 'acceptedDataUsage';

  FutureResult<PrivacyData> fetchPrivacyData();

  Future<bool> savePrivacyData(PrivacyData privacyData);

  Future<void> toggleAllowErrorReporting({bool? value});

  Future<void> toggleAcceptedAppDataUsage({bool? value});

  String generateRandomSecurePassword(int length);
}
