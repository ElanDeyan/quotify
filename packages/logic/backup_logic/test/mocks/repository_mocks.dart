import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/repositories/quotes_repository.dart';
import 'package:tags_repository/repositories/tag_repository.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository.dart';

final class MockThemeBrightnessRepository extends Mock
    implements ThemeBrightnessRepository {}

final class MockPrimaryColorsRepository extends Mock
    implements PrimaryColorsRepository {}

final class MockLanguagesRepository extends Mock
    implements LanguagesRepository {}

final class MockPrivacyRepository extends Mock implements PrivacyRepository {}

final class MockTagRepository extends Mock implements TagRepository {}

final class MockQuotesRepository extends Mock implements QuotesRepository {}
