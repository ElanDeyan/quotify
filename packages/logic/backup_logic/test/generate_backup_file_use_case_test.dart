import 'package:backup_logic/backup_logic.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:quotify_utils/result.dart';

import 'utils/fake_path_provider_platform.dart';
import 'utils/sample_backup_generator.dart';
import 'utils/sample_backup_password_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });
  group('on successful case', () {
    late Backup sampleBackup;
    late BackupPassword samplePassword;

    setUp(() {
      sampleBackup = sampleBackupGenerator();
      samplePassword = sampleBackupPasswordGenerator();
    });

    test('should return Ok with a XFile', () async {
      final generateBackupFile = GenerateBackupFile(
        backup: sampleBackup,
        password: samplePassword,
      );

      final result = await generateBackupFile();

      expect(result, isA<Ok<XFile, BackupErrors>>());
    });

    test('should return Ok with a XFile with expected extension', () async {
      final generateBackupFile = GenerateBackupFile(
        backup: sampleBackup,
        password: samplePassword,
      );

      final result = await generateBackupFile();

      expect(result, isA<Ok<XFile, BackupErrors>>());

      final XFile(:name) = result.asOk.value;

      expect(name, endsWith(Backup.backupFileExtension));
    });

    test('should return Ok with a XFile '
        "with backup's name 'quotify_backup_{hashCode}'", () async {
      final generateBackupFile = GenerateBackupFile(
        backup: sampleBackup,
        password: samplePassword,
      );

      final result = await generateBackupFile();

      expect(result, isA<Ok<XFile, BackupErrors>>());

      final XFile(:name) = result.asOk.value;

      expect(
        name,
        equals(
          'quotify_backup_${sampleBackup.hashCode}'
          '${Backup.backupFileExtension}',
        ),
      );
    });

    test(
      'should return Ok with a file that has encrypted backup json string',
      () async {
        final generateBackupFile = GenerateBackupFile(
          backup: sampleBackup,
          password: samplePassword,
        );

        final result = await generateBackupFile();

        expect(result, isA<Ok<XFile, BackupErrors>>());

        final fileContent = await result.asOk.value.readAsString();

        expect(fileContent, isNot(sampleBackup.toJsonString()));
      },
    );
  });
}
