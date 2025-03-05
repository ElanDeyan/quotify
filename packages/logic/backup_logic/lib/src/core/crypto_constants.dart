import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';
import 'package:quotify_utils/quotify_utils.dart';

/// Default length for the [IV].
const ivLength = 16;

/// Default length for the salt.
const saltLength = 32;

KdfAlgorithm get kdfAlgorithm =>
    Argon2id(hashLength: 32, iterations: 3, memory: 2048, parallelism: 2);

Uint8List getSaltByLength(Natural length) => Uint8List.fromList([
  for (var i = 0; i < length.toInt(); i++) Random.secure().nextInt(256),
]);

Future<SecretKey> deriveKeyFromPassword(
  String password, {
  required Uint8List salt,
}) => kdfAlgorithm.deriveKeyFromPassword(password: password, nonce: salt);

Algorithm encryptionAlgorithm(Key key) => AES(key);
