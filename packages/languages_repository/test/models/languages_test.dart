import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' as glados;
import 'package:languages_repository/models/language_model_errors.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:quotify_utils/result.dart';

import '../../testing/languages_generator.dart';

void main() {
  group('With valid language ', () {
    glados.Glados(glados.any.languages).test(
      'Languages.fromString returns the correct enum member',
      (input) {
        final result = Languages.fromLanguageCodeString(input.languageCode);
        check(result).isA<Ok<Languages, LanguageModelErrors>>().which(
          (okSubject) => okSubject.has((ok) => ok.value, 'value').equals(input),
        );
      },
    );
  });

  group('With random strings for language code ', () {
    glados.Glados(glados.any.stringOf('abcdefghijklmnopqrstuvwxyz')).test(
      'Languages.fromString should return a Failure with '
      'LanguageErrors.invalidLanguageCode',
      (input) {
        final result = Languages.fromLanguageCodeString(input);
        final languagesCodes = Languages.values.map((e) => e.languageCode);

        if (languagesCodes.contains(input)) {
          check(result).isA<Ok<Languages, LanguageModelErrors>>().which(
            (okSubject) => okSubject
                .has((ok) => ok.value.languageCode, 'value.languageCode')
                .equals(input),
          );
        } else {
          check(result).isA<Failure<Languages, LanguageModelErrors>>().which(
            (failureResult) => failureResult
                .has((failure) => failure.failure, 'failure')
                .equals(LanguageModelErrors.invalidLanguageCodeRepresentation),
          );
        }
      },
    );
  });
}
