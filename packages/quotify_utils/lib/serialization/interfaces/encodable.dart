/// An interface for objects that can be converted to a [Map] or a JSON
/// [String].
abstract interface class Encodable {
  /// Converts the object to a [Map] that can be serialized to JSON.
  Map<String, Object?> toMap();

  /// Converts the object to a JSON [String].
  String toJsonString();
}
