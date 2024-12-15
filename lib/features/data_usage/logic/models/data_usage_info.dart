import 'package:pub_semver/pub_semver.dart';

import 'section.dart';

final class DataUsageInfo {
  DataUsageInfo({
    required this.title,
    required this.introduction,
    required this.lastUpdated,
    required this.version,
    required this.whatDataIsCollected,
    required this.whyDataIsCollected,
    required this.howIsDataStored,
    required this.whoHasAccessToTheData,
    required this.howCanUsersManageTheirData,
    required this.changesToPrivacyPolicy,
  });

  final String title;
  final String introduction;
  final DateTime lastUpdated;
  final Version version;
  final ContentSection whatDataIsCollected;
  final ContentSection whyDataIsCollected;
  final ContentSection howIsDataStored;
  final ContentSection whoHasAccessToTheData;
  final ContentSection howCanUsersManageTheirData;
  final ContentSection changesToPrivacyPolicy;
}
