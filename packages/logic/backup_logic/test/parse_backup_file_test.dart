import 'package:backup_logic/backup_logic.dart';
import 'package:backup_logic/src/use_cases/parse_backup_file.dart';
import 'package:cross_file/cross_file.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotify_utils/result.dart';

import 'utils/sample_backup_generator.dart';

void main() {
  late Backup sampleBackup;
  late Min8LengthPassword password;
  late XFile sampleBackupFile;

  setUp(() async {
    sampleBackup = sampleBackupGenerator();
    password = Min8LengthPassword(faker.randomGenerator.numberOfLength(8));
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
      final differentPassword = Min8LengthPassword(
        faker.randomGenerator.numberOfLength(8),
      );

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
