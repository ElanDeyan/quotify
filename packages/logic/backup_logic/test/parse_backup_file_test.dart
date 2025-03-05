import 'package:backup_logic/backup_logic.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotify_utils/result.dart';

import 'utils/sample_backup_generator.dart';
import 'utils/sample_backup_password_generator.dart';

void main() {
  late Backup sampleBackup;
  late BackupPassword password;
  late XFile sampleBackupFile;

  setUp(() async {
    sampleBackup = sampleBackupGenerator();
    password = sampleBackupPasswordGenerator();
    sampleBackupFile =
        (await GenerateBackupFile(backup: sampleBackup, password: password)())
            .asOk
            .value;
  });

  test('if same password, should return the same backup instance', () async {
    final parseBackupFileUseCase = ParseBackupFile(
      file: sampleBackupFile,
      password: password,
    );

    final parsedBackup = await parseBackupFileUseCase();

    expect(parsedBackup, isA<Ok<Backup, BackupErrors>>());

    expect(parsedBackup.asOk.value, equals(sampleBackup));
  });

  test(
    'if different password, should return a failure with a backup error',
    () async {
      final differentPassword = sampleBackupPasswordGenerator();

      expect(password, isNot(differentPassword));

      final parseBackupFileUseCase = ParseBackupFile(
        file: sampleBackupFile,
        password: differentPassword,
      );

      final parsedBackup = await parseBackupFileUseCase();

      expect(parsedBackup, isA<Failure<Backup, BackupErrors>>());

      expect(
        parsedBackup.asFailure.failure,
        equals(BackupUseCasesErrors.failAtDecryptingBackup),
      );
    },
  );
}
