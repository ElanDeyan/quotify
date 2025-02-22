import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';

final class RestoreBackup
    implements
        UseCase<({Backup backup}), FutureResult<Unit, BackupUseCasesErrors>> {
  @override
  FutureResult<Unit, BackupUseCasesErrors> call([
    ({Backup backup})? arguments,
  ]) {
    assert(arguments != null, 'Should be non-null');
    // TODO: implement call
    throw UnimplementedError();
  }
}
