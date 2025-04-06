import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:primary_colors_repository/models/primary_colors_model_errors.dart';
import 'package:quotify_utils/result.dart';

Iterable<String> _generateWrongPrimaryColorStringRepresentation() sync* {
  final primaryColorsNames = PrimaryColors.values.map((color) => color.name);
  while (true) {
    final string = faker.lorem.word();

    if (!primaryColorsNames.contains(string)) yield string;
  }
}

void main() {
  const primaryColorsNames = PrimaryColors.values;

  group('PrimaryColors.fromString', () {
    late Iterable<String> wrongSamples;

    setUp(() {
      wrongSamples = _generateWrongPrimaryColorStringRepresentation().take(10);
    });

    test(
      'Name of PrimaryColors enum member should return equivalent instance',
      () {
        for (final color in primaryColorsNames) {
          expect(
            PrimaryColors.fromString(color.name),
            allOf([
              isA<Ok<PrimaryColors, PrimaryColorsModelErrors>>(),
              predicate(
                (Ok<PrimaryColors, PrimaryColorsModelErrors> result) =>
                    result.value == color,
              ),
            ]),
          );
        }
      },
    );

    test('Non valid string should return '
        'PrimaryColorsErrors.invalidStringRepresentation', () {
      for (final wrongSample in wrongSamples) {
        expect(
          PrimaryColors.fromString(wrongSample),
          allOf([
            isA<Failure<PrimaryColors, PrimaryColorsModelErrors>>(),
            predicate(
              (Failure<PrimaryColors, PrimaryColorsModelErrors> result) =>
                  result.failure ==
                  PrimaryColorsModelErrors.invalidStringRepresentation,
            ),
          ]),
        );
      }
    });
  });
}
