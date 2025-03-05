/// https://github.com/flutter/samples/blob/main/compass_app/app/test/domain/use_cases/booking/booking_share_use_case_test.dart
library;

import 'package:backup_logic/backup_logic.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/sample_backup_generator.dart';
import 'utils/sample_backup_password_generator.dart';

void main() {
  test('sharing backup file', () async {
    late XFile? sharedFile;
    final generateBackupFileUseCase = GenerateBackupFile(
      backup: sampleBackupGenerator(),
      password: sampleBackupPasswordGenerator(),
    );

    final backupFile = (await generateBackupFileUseCase()).asOk.value;

    final shareBackupFileUseCase = ShareBackupFile.withCustomHandler(
      handler: (file) async => sharedFile = file,
      backupFile: backupFile,
    );

    await shareBackupFileUseCase();

    expect(sharedFile, isNotNull);
    expect(sharedFile!.name, backupFile.name);
    expect(sharedFile!.path, backupFile.path);
  });
}
