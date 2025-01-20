import 'language_errors.dart';
import 'languages.dart';

/// This enum can be used to represent different types of [Languages]-related
/// errors in a Dart program. By implementing the
/// [Exception] class, instances of [LanguageModelErrors] can be thrown as
/// exceptions in the program when errors related to language codes occur.
enum LanguageModelErrors implements LanguageErrors {
  /// This error can be thrown as an exception when there is an issue with the
  /// representation of a language code.
  invalidLanguageCodeRepresentation,
}
