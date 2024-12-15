import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:languages_repository/models/language_errors.dart';
import 'package:languages_repository/models/languages.dart';
import 'package:quotify_utils/quotify_utils.dart';

void main() {
  group('With valid language', () {
    test('Languages.fromString should return the correct language', () {
      const samples = Languages.values;

      for (final sample in samples) {
        final result = Languages.fromLanguageCodeString(sample.languageCode);
        expect(result, isA<Ok<Languages>>());
        expect(result.asOk.value, equals(sample));
      }
    });
  });

  group('With invalid language code', () {
    test(
        'Languages.fromString should return a Failure with '
        'LanguageErrors.invalidLanguageCode', () {
      final samples = faker.lorem.words(20)
        ..removeWhere(
          (word) => Languages.values.map((e) => e.languageCode).contains(word),
        );

      for (final sample in samples) {
        final result = Languages.fromLanguageCodeString(sample);
        expect(result, isA<Failure<Languages>>());
        expect(
          result.asFailure.failure,
          equals(LanguageErrors.invalidLanguageCodeRepresentation),
        );
      }
    });
  });
}
