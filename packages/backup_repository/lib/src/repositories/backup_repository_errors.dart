import '../models/backup_errors.dart';

enum BackupRepositoryErrors implements BackupErrors {
  failAtRequestingThemeBrightnessRepository,
  failAtRequestingPrimaryColorsRepository,
  failAtRequestingLanguagesRepository,
  failAtRequestingPrivacyRepository,
  unknown,
}
