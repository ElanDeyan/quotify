// FutureResult<Backup, BackupErrors> parseBackupFile(
//   XFile file, {
//   required Min8LengthPassword password,
// });

import 'package:cross_file/cross_file.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';

final class ParseBackupFile
    implements UseCase<FutureResult<Backup, BackupErrors>> {
  const ParseBackupFile({required this.file, required this.password});

  final XFile file;
  final Min8LengthPassword password;
  @override
  FutureResult<Backup, BackupErrors> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}
