import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service that forwards commands to [FlutterSecureStorage].
interface class FlutterSecureStorageService {
  /// A service that forwards commands to [FlutterSecureStorage].
  const FlutterSecureStorageService({
    required FlutterSecureStorage flutterSecureStorage,
  }) : _flutterSecureStorage = flutterSecureStorage;

  final FlutterSecureStorage _flutterSecureStorage;

  /// Reads a value from a [key] in secure storage.
  Future<String?> read(
    String key, {
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
  }) =>
      _flutterSecureStorage.read(
        key: key,
        aOptions: androidOptions ?? _flutterSecureStorage.aOptions,
        iOptions: iosOptions ?? _flutterSecureStorage.iOptions,
      );

  /// Writes the [value] to the provided [key].
  Future<void> write(
    String key,
    String value, {
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
  }) =>
      _flutterSecureStorage.write(
        key: key,
        value: value,
        aOptions: androidOptions ?? _flutterSecureStorage.aOptions,
        iOptions: iosOptions ?? _flutterSecureStorage.iOptions,
      );

  /// Checks if the [key] exists.
  Future<bool> containsKey(
    String key, {
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
  }) =>
      _flutterSecureStorage.containsKey(
        key: key,
        aOptions: androidOptions ?? _flutterSecureStorage.aOptions,
        iOptions: iosOptions ?? _flutterSecureStorage.iOptions,
      );
}
