import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';

final class RestoreBackup
    implements UseCase<FutureResult<Unit, BackupUseCasesErrors>> {
  const RestoreBackup({required this.backup});

  final Backup backup;
  @override
  FutureResult<Unit, BackupUseCasesErrors> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}
