import '../../../utils/future_result.dart';
import '../logic/models/backup.dart';

abstract interface class BackupRepository {
  FutureResult<Backup> fetchBackupData();
}
