import '../models/backup_errors.dart';

enum BackupUseCasesErrors implements BackupErrors {
  failAtRequestingThemeBrightnessRepository,
  failAtRequestingPrimaryColorsRepository,
  failAtRequestingLanguagesRepository,
  failAtRequestingPrivacyRepository,
  failAtDecryptingBackup,
  unknown,
}
