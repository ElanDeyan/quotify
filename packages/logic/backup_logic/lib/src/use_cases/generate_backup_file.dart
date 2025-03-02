import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:encrypt/encrypt.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';
import '../core/crypto_utils.dart';

final class GenerateBackupFile
    implements UseCase<FutureResult<XFile, BackupErrors>> {
  const GenerateBackupFile({required this.backup, required this.password});

  final Backup backup;
  final Min8LengthPassword password;

  @override
  FutureResult<XFile, BackupErrors> call() async {
    final backupAsJsonString = backup.toJsonString();
    final backupFileName = backup.backupFileNameWithExtension;

    final path = await backupFileTempPath;

    final tempFile = File(path);
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
    tempFile.createSync(recursive: true);

    final fileBytes = await Result.guardAsync(
      () => Isolate.run(
        () => _encryptBackupJsonString(backupAsJsonString, password),
        debugName: 'EncryptBackup#${backup.hashCode}',
      ),
    );

    if (fileBytes case Ok(value: final fileBytes)) {
      try {
        return Result.ok(XFile(path, bytes: fileBytes, name: backupFileName));
      } finally {
        tempFile.deleteSync();
      }
    }

    return const Result.failure(BackupUseCasesErrors.unknown);
  }

  @visibleForTesting
  Future<String> get backupFileTempPath async =>
      '${(await getApplicationCacheDirectory()).path}'
      '/quotify/backup/${backup.backupFileNameWithExtension}';

  /// Return a [Uint8List] following the pattern:
  /// salt ([saltLength]) + IV ([ivLength]) + [encrypted cipher text]
  Future<Uint8List> _encryptBackupJsonString(
    String jsonString,
    Min8LengthPassword password,
  ) async {
    final salt = [
      for (var i = 0; i < saltLength; i++) Random.secure().nextInt(256),
    ];

    final newSecretKey = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final secretKeyBytes = Uint8List.fromList(
      await newSecretKey.extractBytes(),
    );

    final key = Key(secretKeyBytes);
    final iv = IV.fromSecureRandom(ivLength);

    // Keeping default value to be clear
    // ignore: avoid_redundant_argument_values
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    final encryptedData = encrypter.encrypt(jsonString, iv: iv);

    final encryptedDataWithSaltAndIvPrepended = Uint8List.fromList([
      ...salt,
      ...iv.bytes,
      ...encryptedData.bytes,
    ]);

    return encryptedDataWithSaltAndIvPrepended;
  }
}
