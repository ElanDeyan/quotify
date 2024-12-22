import 'dart:convert';

import 'package:logging/logging.dart';

import '../exceptions/serialization_exceptions.dart';

/// An interface for objects that can be converted to a [Map] or a JSON
/// [String].
abstract interface class Encodable {
  static final _log = Logger('Encodable');

  /// Converts the object to a [Map] that can be serialized to JSON.
  Map<String, Object?> toMap();

  /// Converts the object to a JSON [String].
  ///
  /// Throws [NoEncodableException] if the object cannot be encoded to JSON.
  String toJsonString() {
    try {
      return jsonEncode(toMap());
    } catch (e, stackTrace) {
      _log.severe('Error encoding object to JSON', e, stackTrace);
      throw NoEncodableException(
        encodable: this,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
