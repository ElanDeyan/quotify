/// Shameless copied from
/// https://github.com/flutter/samples/blob/main/compass_app/app/lib/domain/use_cases/booking/booking_share_use_case.dart
library;

import 'package:quotify_utils/quotify_utils.dart';
import 'package:share_plus/share_plus.dart';

/// Shameless copied from
/// https://github.com/flutter/samples/blob/main/compass_app/app/lib/domain/use_cases/booking/booking_share_use_case.dart
typedef ShareBackupFileHandler = Future<void> Function(XFile file);

/// Shameless copied from
/// https://github.com/flutter/samples/blob/main/compass_app/app/lib/domain/use_cases/booking/booking_share_use_case.dart
final class ShareBackupFile implements UseCase<void> {
  const ShareBackupFile._({
    required ShareBackupFileHandler handler,
    required XFile backupFile,
  }) : _handler = handler,
       _backupFile = backupFile;

  factory ShareBackupFile.withSharePlus(XFile file) => ShareBackupFile._(
    handler: (file) => Share.shareXFiles([file]),
    backupFile: file,
  );

  const factory ShareBackupFile.withCustomHandler({
    required ShareBackupFileHandler handler,
    required XFile backupFile,
  }) = ShareBackupFile._;

  final ShareBackupFileHandler _handler;
  final XFile _backupFile;

  @override
  Future<void> call() => _handler(_backupFile);
}
