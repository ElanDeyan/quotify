import 'backup_errors.dart';

enum BackupModelErrors implements BackupErrors {
  invalidMapRepresentation,
  invalidJsonString,
  invalidThemeBrightness,
  invalidPrimaryColor,
  invalidLanguageCode,
  invalidPrivacyDataMap,
  missingListOfMaps,
  atLeastOneInvalidTagMap,
  atLeastOneInvalidQuoteMap,
}
