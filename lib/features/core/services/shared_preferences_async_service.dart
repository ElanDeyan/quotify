import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service for the [SharedPreferencesAsync].
final class SharedPreferencesAsyncService {
  /// Constructor for the [SharedPreferencesAsyncService] class.
  /// It takes a parameter of type [SharedPreferencesAsync].
  const SharedPreferencesAsyncService(this._sharedPreferencesAsync);

  /// This variable will hold an instance of the [SharedPreferencesAsync] class.
  final SharedPreferencesAsync _sharedPreferencesAsync;

  /// This variable is used for logging messages related to the
  /// [SharedPreferencesAsyncService] class.
  static final sharedPreferencesAsyncServiceLogger =
      Logger('SharedPreferencesAsyncService');

  /// The function `containsKey` checks if a key exists in the shared
  /// preferences asynchronously and returns a Future<bool>
  /// indicating the result.
  ///
  /// Args:
  ///   [key] ([String]): The [key] parameter is a string that represents the
  /// [key] to check for existence in the shared preferences.
  Future<bool> containsKey(String key) =>
      _sharedPreferencesAsync.containsKey(key);

  /// Sets a string value in shared preferences asynchronously.
  ///
  /// Args:
  ///
  ///   [key] ([String]): A unique identifier used to store and retrieve the
  ///   [value] in the shared preferences.
  ///
  ///   [value] ([String]): The value parameter is a string that you want
  ///   to store in the shared preferences with the corresponding [key].
  Future<void> setString(String key, String value) =>
      _sharedPreferencesAsync.setString(key, value);

  /// Retrieves a [String] value associated with a given [key] from shared
  /// preferences asynchronously.
  ///
  /// Args:
  ///   [key] ([String]): The [key] parameter is a unique identifier used
  /// to retrieve a specific value from the shared preferences.
  Future<String?> getString(String key) =>
      _sharedPreferencesAsync.getString(key);
}
