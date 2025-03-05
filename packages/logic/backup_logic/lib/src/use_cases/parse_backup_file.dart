import 'dart:isolate';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:encrypt/encrypt.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../../backup_logic.dart';
import '../core/crypto_constants.dart';

final class ParseBackupFile
    implements UseCase<FutureResult<Backup, BackupErrors>> {
  const ParseBackupFile({required XFile file, required BackupPassword password})
    : _password = password,
      _backupFile = file;

  final XFile _backupFile;
  final BackupPassword _password;
  @override
  FutureResult<Backup, BackupErrors> call() async {
    final fileBytes = await _backupFile.readAsBytes();

    final (saltStartIndex, saltEndIndex) = (0, saltLength);
    final (ivStartIndex, ivEndIndex) = (saltEndIndex, saltEndIndex + ivLength);

    final salt = fileBytes.sublist(saltStartIndex, saltEndIndex);
    final iv = fileBytes.sublist(ivStartIndex, ivEndIndex);
    final contentBytes = fileBytes.sublist(ivEndIndex);

    final decryptedDataResult = await Isolate.run(
      () => Result.guardAsync(
        () => _decryptBackupFileDataBytes(
          saltBytes: salt,
          ivBytes: iv,
          fileEncryptedContentAsBytes: contentBytes,
          password: _password,
        ),
      ),
      debugName: '_decryptBackupFileData',
    );

    if (decryptedDataResult case Ok(:final value)) {
      return Backup.fromJsonString(value);
    }

    return const Result.failure(BackupUseCasesErrors.failAtDecryptingBackup);
  }

  Future<String> _decryptBackupFileDataBytes({
    required Uint8List saltBytes,
    required Uint8List ivBytes,
    required Uint8List fileEncryptedContentAsBytes,
    required BackupPassword password,
  }) async {
    final secretKey = await deriveKeyFromPassword(password, salt: saltBytes);

    final secretKeyBytes = Uint8List.fromList(await secretKey.extractBytes());
    final key = Key(secretKeyBytes);
    final iv = IV(ivBytes);

    final encrypter = Encrypter(encryptionAlgorithm(key));
    final encryptedContent = Encrypted(fileEncryptedContentAsBytes);

    final decryptedData = encrypter.decrypt(encryptedContent, iv: iv);

    return decryptedData;
  }
}
