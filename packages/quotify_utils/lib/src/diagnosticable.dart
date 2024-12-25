// Because this class is intended to be implemented in others.
// ignore_for_file: one_member_abstracts

/// An abstract interface that defines a diagnosticable object.
///
/// This interface is intended to be implemented by classes that need to
/// provide a diagnostic string representation of their instances.
///
/// [T] is a generic type that extends [Object].
abstract interface class Diagnosticable<T extends Object> {
  /// Returns a string representation of the object for diagnostic purposes.
  ///
  /// This method should be overridden by implementing classes to provide
  /// a detailed and meaningful diagnostic string.
  ///
  /// Returns a [String] that represents the diagnostic information
  /// of the object.
  String toDiagnosticableString();
}
