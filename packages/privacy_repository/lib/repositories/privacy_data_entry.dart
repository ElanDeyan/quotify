import '../logic/models/privacy_data.dart';
import 'privacy_repository.dart';

/// Entry to add [PrivacyData] to [PrivacyRepository].
final class PrivacyDataEntry {
  /// Entry to add [PrivacyData] to [PrivacyRepository].
  const PrivacyDataEntry({
    this.allowErrorReporting,
    this.acceptedDataUsage,
  });

  /// Creates an instance from [PrivacyData].
  factory PrivacyDataEntry.fromPrivacyData(PrivacyData privacyData) =>
      PrivacyDataEntry(
        allowErrorReporting: privacyData.allowErrorReporting,
        acceptedDataUsage: privacyData.acceptedDataUsage,
      );

  /// Related to [PrivacyData.allowErrorReporting].
  final bool? allowErrorReporting;

  /// Related to [PrivacyData.acceptedDataUsage].
  final bool? acceptedDataUsage;

  /// Helper to convert this to [PrivacyData].
  PrivacyData toPrivacyData() => PrivacyData(
        allowErrorReporting: allowErrorReporting ?? false,
        acceptedDataUsage: acceptedDataUsage ?? false,
      );
}
