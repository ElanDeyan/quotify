// FutureResult<XFile, BackupErrors> generateBackupFile({
//     required Min8LengthPassword password,
//   });

import 'package:cross_file/cross_file.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';

final class GenerateBackupFile
    implements
        UseCase<
          ({Min8LengthPassword password}),
          FutureResult<XFile, BackupErrors>
        > {
  @override
  FutureResult<XFile, BackupErrors> call([
    ({Min8LengthPassword password})? arguments,
  ]) {
    assert(arguments != null, 'Should be non-null');
    // TODO: implement call

    throw UnimplementedError();
  }
}
