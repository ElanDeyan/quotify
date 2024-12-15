import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness_errors.dart';

void main() {
  group('ThemeBrightness.fromString', () {
    test('with "dark" should return ThemeBrightness.dark', () {
      final dark = ThemeBrightness.dark.name;

      expect(
        ThemeBrightness.fromString(dark),
        allOf([
          isA<Ok<ThemeBrightness>>(),
          predicate(
            (Result<ThemeBrightness> result) =>
                result.asOk.value == ThemeBrightness.dark,
          ),
        ]),
      );
    });
    test('with "light" should return ThemeBrightness.light', () {
      final light = ThemeBrightness.light.name;

      expect(
        ThemeBrightness.fromString(light),
        allOf([
          isA<Ok<ThemeBrightness>>(),
          predicate(
            (Result<ThemeBrightness> result) =>
                result.asOk.value == ThemeBrightness.light,
          ),
        ]),
      );
    });
    test('with "system" should return ThemeBrightness.system', () {
      final system = ThemeBrightness.system.name;

      expect(
        ThemeBrightness.fromString(system),
        allOf([
          isA<Ok<ThemeBrightness>>(),
          predicate(
            (Result<ThemeBrightness> result) =>
                result.asOk.value == ThemeBrightness.system,
          ),
        ]),
      );
    });

    test(
      'with any invalid string, should return Failure with '
      'ThemeBrightnessErrors.invalidStringRepresentation',
      () {
        final samples = faker.lorem.words(20)
          ..removeWhere(
            (word) => ThemeBrightness.values
                .map((theme) => theme.name)
                .contains(word),
          );

        for (final sample in samples) {
          expect(
            ThemeBrightness.fromString(sample),
            allOf([
              isA<Failure<ThemeBrightness>>(),
              predicate(
                (Result<ThemeBrightness> result) =>
                    result.asFailure.failure ==
                    ThemeBrightnessErrors.invalidStringRepresentation,
              ),
            ]),
          );
        }
      },
    );
  });
}
