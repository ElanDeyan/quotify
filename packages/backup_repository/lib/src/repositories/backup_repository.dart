import 'package:cross_file/cross_file.dart';
import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/repositories/quotes_repository.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/repositories/tag_repository.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository.dart';

import '../models/backup.dart';
import '../models/backup_errors.dart';
import '../models/min_8_length_password.dart';
import 'backup_repository_errors.dart';

/// Interface for operations related to the [Backup] feature.
abstract interface class BackupRepository {
  const BackupRepository({
    required this.themeBrightnessRepository,
    required this.quotesRepository,
    required this.tagRepository,
    required this.languagesRepository,
    required this.primaryColorsRepository,
    required this.privacyRepository,
  });

  final QuotesRepository quotesRepository;

  final TagRepository tagRepository;

  final LanguagesRepository languagesRepository;

  final PrimaryColorsRepository primaryColorsRepository;

  final PrivacyRepository privacyRepository;

  final ThemeBrightnessRepository themeBrightnessRepository;

  FutureResult<Backup, BackupRepositoryErrors>  fetchBackup();

  FutureResult<Unit, BackupRepositoryErrors> restoreBackup(Backup backup);

  FutureResult<Backup, BackupErrors> parseBackupFile(
    XFile file, {
    required Min8LengthPassword password,
  });

  FutureResult<XFile, BackupErrors> generateBackupFile({
    required Min8LengthPassword password,
  });
}
