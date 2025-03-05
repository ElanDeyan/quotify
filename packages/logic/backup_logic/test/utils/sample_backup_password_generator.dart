import 'package:backup_logic/backup_logic.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';

BackupPassword sampleBackupPasswordGenerator() {
  final lowerCaseLetters = faker.randomGenerator.fromCharSet(
    'abcdefghijklmnopqrstuvwxyz',
    3,
  );
  final upperCaseLetters = faker.randomGenerator.fromCharSet(
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    3,
  );
  final specialChars = faker.randomGenerator.fromCharSet(
    r'!@#$%^&*(),.?":{}|<>',
    3,
  );

  final digits = faker.randomGenerator.fromCharSet('0123456789', 3);

  final passwordBuffer =
      StringBuffer()
        ..writeAll([lowerCaseLetters, upperCaseLetters, specialChars, digits]);

  return BackupPassword(passwordBuffer.toString().split('').shuffled().join());
}
