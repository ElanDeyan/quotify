import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:encrypt/encrypt.dart';
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

    final fileBytes = await Isolate.run(
      () => _encryptBackupJsonString(backupAsJsonString, password),
    );

    final xFile = XFile.fromData(
      fileBytes,
      name: backupFileName,
      path: backupFileName,
    );

    return Result.ok(xFile);
  }

  /// Return a [Uint8List] following the pattern:
  /// salt ([saltLength]) + IV ([ivLength]) + [encrypted cipher text]
  Future<Uint8List> _encryptBackupJsonString(
    String jsonString,
    Min8LengthPassword password,
  ) async {
    final salt = [
      for (var i = 0; i < saltLength; i++) Random.secure().nextInt(256),
    ];

    final newSecretKey = await argon2id.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final secretKeyBytes = Uint8List.fromList(
      await newSecretKey.extractBytes(),
    );

    final key = Key(secretKeyBytes);
    final iv = IV.fromSecureRandom(ivLength);

    // Keeping default value of padding to be clear
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
