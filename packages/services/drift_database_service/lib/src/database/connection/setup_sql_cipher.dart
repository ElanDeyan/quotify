import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

/// Sets up SQLCipher for use in the application.
///
/// This function applies a workaround to open SQLCipher on older Android
///  versions and overrides the default database opening method for Android to
/// use SQLCipher.
///
/// It is an asynchronous function and should be awaited to ensure the setup
/// is complete before proceeding with database operations.
Future<void> setupSqlCipher() async {
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
}
