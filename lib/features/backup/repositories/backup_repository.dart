import 'package:quotify_utils/result.dart';

import '../logic/models/backup.dart';

abstract interface class BackupRepository {
  FutureResult<Backup, Exception> fetchBackupData();
}
