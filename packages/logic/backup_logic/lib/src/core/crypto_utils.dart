import 'package:cryptography/cryptography.dart';

const ivLength = 16;
const saltLength = 32;

Argon2id get argon2id =>
    Argon2id(hashLength: 32, iterations: 3, memory: 2048, parallelism: 2);
