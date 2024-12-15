import 'languages.dart';

/// This enum can be used to represent different types of [Languages]-related
/// errors in a Dart program. By implementing the
/// [Exception] class, instances of [LanguageErrors] can be thrown as
/// exceptions in the program when errors related to language codes occur.
enum LanguageErrors implements Exception {
  /// This error can be thrown as an exception when there is an issue with the
  /// representation of a language code.
  invalidLanguageCodeRepresentation,
}
