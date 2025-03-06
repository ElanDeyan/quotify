import 'dart:typed_data';

import 'package:backup_logic/backup_logic.dart';
import 'package:backup_logic/src/core/crypto_constants.dart';
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

  test('when wrong file extension, returns a failure', () async {
    final sampleFile = XFile.fromData(
      Uint8List(200),
      name: 'sample.txt',
      path: 'sample.txt',
    );

    final parseBackupFile = ParseBackupFile(
      file: sampleFile,
      password: password,
    );

    final result = await parseBackupFile();

    expect(result, isA<Failure<Backup, BackupErrors>>());
    expect(
      result.asFailure.failure,
      equals(BackupUseCasesErrors.wrongFileExtension),
    );
  });

  group('when file has a length less or equal than '
      'salt + iv lengths, returns a failure', () {
    test('like 0 length', () async {
      final sampleFile1 = XFile.fromData(
        Uint8List(0),
        name: sampleBackup.backupFileNameWithExtension,
        path: sampleBackup.backupFileNameWithExtension,
      );

      final parseBackupFile = ParseBackupFile(
        file: sampleFile1,
        password: password,
      );

      final result = await parseBackupFile();

      expect(result, isA<Failure<Backup, BackupErrors>>());
      expect(
        result.asFailure.failure,
        equals(BackupUseCasesErrors.backupFileLengthIsTooShort),
      );
    });

    test('like == ivLength + saltLength', () async {
      final sampleFile1 = XFile.fromData(
        Uint8List(saltLength + ivLength),
        name: sampleBackup.backupFileNameWithExtension,
        path: sampleBackup.backupFileNameWithExtension,
      );

      final parseBackupFile = ParseBackupFile(
        file: sampleFile1,
        password: password,
      );

      final result = await parseBackupFile();

      expect(result, isA<Failure<Backup, BackupErrors>>());
      expect(
        result.asFailure.failure,
        equals(BackupUseCasesErrors.backupFileLengthIsTooShort),
      );
    });

    test('but with more than ivLength + saltLength he goes to parse', () async {
      final sampleFile1 = XFile.fromData(
        Uint8List(saltLength + ivLength + 1),
        name: sampleBackup.backupFileNameWithExtension,
        path: sampleBackup.backupFileNameWithExtension,
      );

      final parseBackupFile = ParseBackupFile(
        file: sampleFile1,
        password: password,
      );

      final result = await parseBackupFile();

      expect(result, isA<Result<Backup, BackupErrors>>());
    });
  });
}
