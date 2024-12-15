import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/backup.dart';

abstract interface class BackupRepository {
  FutureResult<Backup> fetchBackupData();
}
