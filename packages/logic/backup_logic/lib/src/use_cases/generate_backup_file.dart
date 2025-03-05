import 'dart:isolate';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:encrypt/encrypt.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';
import '../core/crypto_constants.dart';

final class GenerateBackupFile
    implements UseCase<FutureResult<XFile, BackupErrors>> {
  const GenerateBackupFile({
    required Backup backup,
    required BackupPassword password,
  }) : _password = password,
       _backup = backup;

  final Backup _backup;
  final BackupPassword _password;

  @override
  FutureResult<XFile, BackupErrors> call() async {
    final backupAsJsonString = _backup.toJsonString();
    final backupFileName = _backup.backupFileNameWithExtension;

    final fileBytes = await Isolate.run(
      () => _encryptBackupJsonString(backupAsJsonString, _password),
      debugName: 'encryptBackupJsonString',
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
    BackupPassword password,
  ) async {
    final salt = getSaltByLength(saltLength.toNatural());

    final newSecretKey = await deriveKeyFromPassword(password, salt: salt);

    final secretKeyBytes = Uint8List.fromList(
      await newSecretKey.extractBytes(),
    );

    final key = Key(secretKeyBytes);
    final iv = IV.fromSecureRandom(ivLength);

    // Keeping default value of padding to be clear
    // ignore: avoid_redundant_argument_values
    final encrypter = Encrypter(encryptionAlgorithm(key));

    final encryptedData = encrypter.encrypt(jsonString, iv: iv);

    final encryptedDataWithSaltAndIvPrepended = Uint8List.fromList([
      ...salt,
      ...iv.bytes,
      ...encryptedData.bytes,
    ]);

    return encryptedDataWithSaltAndIvPrepended;
  }
}
