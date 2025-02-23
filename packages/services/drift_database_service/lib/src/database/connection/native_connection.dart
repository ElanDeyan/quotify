import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'setup_sql_cipher.dart';

final RootIsolateToken _token = RootIsolateToken.instance!;

/// Establishes a connection to the database using the provided
/// encryption passphrase.
///
/// This function returns a [DatabaseConnection] that is initialized in the
/// background.
/// The database file is encrypted and the connection is set up with SQLCipher.
///
/// The [encryptionPassPhrase] is used to unlock the encrypted database.
///
/// The connection setup includes:
/// - Ensuring the background isolate is initialized.
/// - Setting up SQLCipher for encryption.
/// - Configuring the database to use the provided encryption passphrase.
/// - Disabling double-quoted string literals for SQLCipher.
///
/// Returns a [DatabaseConnection] that is ready to use.
DatabaseConnection connect(String encryptionPassPhrase) =>
    DatabaseConnection.delayed(
      Future(
        () async => NativeDatabase.createBackgroundConnection(
          File((await _databaseFile).encryptedDbPath),
          isolateSetup: () async {
            BackgroundIsolateBinaryMessenger.ensureInitialized(_token);
            await setupSqlCipher();
          },
          setup: (database) {
            assert(
              _debugCheckHasCipher(database),
              'Read more in '
              'https://drift.simonbinder.eu/platforms/encryption/?h=sqlciph#important-notice',
            );
            database.execute("PRAGMA key = '$encryptionPassPhrase';");

            // Recommended option, not enabled by default on SQLCipher
            database.config.doubleQuotedStringLiterals = false;
          },
        ),
      ),
    );

Future<({String encryptedDbPath, String nonEncryptedDbPath})>
    get _databaseFile async {
  final appDir = await getApplicationDocumentsDirectory();

  final encryptedDbPath = p.join(appDir.path, 'quotify.db.enc');
  final nonEncryptedDbPath = p.join(appDir.path, 'quotify.db');

  return (
    encryptedDbPath: encryptedDbPath,
    nonEncryptedDbPath: nonEncryptedDbPath
  );
}

bool _debugCheckHasCipher(Database database) {
  return database.select('PRAGMA cipher_version;').isNotEmpty;
}
