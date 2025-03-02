import 'package:cryptography/cryptography.dart';

const ivLength = 16;
const saltLength = 16;

final pbkdf2 = Pbkdf2(
  macAlgorithm: Hmac.sha256(),
  iterations: 10000,
  bits: 256,
);
