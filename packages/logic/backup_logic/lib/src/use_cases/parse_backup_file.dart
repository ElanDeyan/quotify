// FutureResult<Backup, BackupErrors> parseBackupFile(
//   XFile file, {
//   required Min8LengthPassword password,
// });

import 'package:cross_file/cross_file.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';

final class ParseBackupFile
    implements
        UseCase<
          (XFile file, {Min8LengthPassword password}),
          FutureResult<Backup, BackupErrors>
        > {
  @override
  FutureResult<Backup, BackupErrors> call([
    (XFile, {Min8LengthPassword password})? arguments,
  ]) {
    assert(arguments != null, 'Should be non-null');
    // TODO: implement call
    throw UnimplementedError();
  }
}
