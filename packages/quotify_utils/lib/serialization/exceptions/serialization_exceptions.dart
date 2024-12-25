import '../interfaces/encodable.dart';

/// An exception thrown when an error occurs during serialization
/// of [Encodable] objects.
sealed class SerializationExceptions implements Exception {
  const SerializationExceptions({
    required this.error,
    required this.stackTrace,
  });

  /// The error that occurred during serialization.
  final Object error;

  /// The stack trace of the error.
  final StackTrace stackTrace;
}

/// An exception thrown when an error occurs during serialization
final class NoEncodableException extends SerializationExceptions {
  /// An exception thrown when an error occurs during serialization
  const NoEncodableException({
    required this.encodable,
    required super.error,
    required super.stackTrace,
  });

  /// The [Encodable] object that caused the error.
  final Encodable encodable;
}
