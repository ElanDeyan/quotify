import '../../../../utils/result.dart';
import 'language_errors.dart';

/// Each enum value has a corresponding [languageCode] property assigned to it.
/// The [languageCode] property is a [String] that holds the language code
/// for each enum value.
enum Languages {
  /// Represents the language code for Brazilian Portuguese (pt_BR).
  brazilianPortuguese(languageCode: 'pt_BR'),

  /// Represents the language code for Spanish (es)
  spanish(languageCode: 'es'),

  /// Represents the language code for English (en)
  english(languageCode: 'en');

  const Languages({required this.languageCode});

  /// Stores the language code associated with each enum value.
  final String languageCode;

  /// Converts a [String] to a [Languages] enum value.
  /// If the [String] is not a valid language code, it returns a
  /// [Result.failure] with [LanguageErrors.invalidLanguageCodeRepresentation].
  static Result<Languages> fromLanguageCodeString(String languageCode) =>
      switch (languageCode) {
        'pt_BR' => const Result.ok(Languages.brazilianPortuguese),
        'es' => const Result.ok(Languages.spanish),
        'en' => const Result.ok(Languages.english),
        _ => Result.failure(
            LanguageErrors.invalidLanguageCodeRepresentation,
            StackTrace.current,
          ),
      };

  /// This variable serves as a default language setting in the
  /// context of the [Languages] enum.
  static const defaultLanguage = Languages.english;
}
