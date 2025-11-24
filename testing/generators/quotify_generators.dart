import 'package:backup_logic/backup_logic.dart';
import 'package:collection/collection.dart';
import 'package:kiri_check/kiri_check.dart' as kiri;
import 'package:languages_repository/models/languages.dart';
import 'package:primary_colors_repository/models/primary_colors.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:theme_brightness_repository/logic/models/theme_brightness.dart';

kiri.Arbitrary<Backup> quotifyBackupGenerator() => kiri
    .combine6(
      themeBrightnessGenerator(),
      primaryColorGenerator(),
      languageGenerator(),
      privacyDataGenerator(),
      kiri.set(tagGenerator()),
      kiri.set(quoteGenerator()),
    )
    .map(
      (tuple) => Backup(
        themeBrightness: tuple.$1,
        primaryColor: tuple.$2,
        language: tuple.$3,
        privacyData: tuple.$4,
        tags: UnmodifiableSetView(tuple.$5),
        quotes: UnmodifiableSetView(tuple.$6),
      ),
    );

kiri.Arbitrary<Quote> quoteGenerator() => kiri
    .combine8(
      naturalIntGenerator(),
      nonBlankStringGenerator(),
      nonBlankStringGenerator(),
      createdAndUpdatedAtGenerator(),
      nullableStringGenerator(),
      nullableUriGenerator(),
      kiri.boolean(),
      kiri.set(tagGenerator()),
    )
    .map(
      (tuple) => Quote(
        id: Id(tuple.$1),
        content: tuple.$2,
        author: tuple.$3,
        createdAt: tuple.$4.createdAt,
        updatedAt: tuple.$4.updatedAt,
        source: tuple.$5,
        sourceUri: tuple.$6,
        isFavorite: tuple.$7,
        tags: UnmodifiableSetView(tuple.$8),
      ),
    );

kiri.Arbitrary<Tag> tagGenerator() => kiri
    .combine2(naturalIntGenerator(), nonBlankStringGenerator())
    .map((tuple) => Tag(id: Id(tuple.$1), label: tuple.$2));

kiri.Arbitrary<PrivacyData> privacyDataGenerator() => kiri
    .combine2(kiri.boolean(), kiri.boolean())
    .map(
      (tuple) => PrivacyData(
        acceptedDataUsage: tuple.$1,
        allowErrorReporting: tuple.$2,
      ),
    );

kiri.Arbitrary<Languages> languageGenerator() =>
    kiri.constantFrom(Languages.values);

kiri.Arbitrary<PrimaryColors> primaryColorGenerator() =>
    kiri.constantFrom(PrimaryColors.values);

kiri.Arbitrary<ThemeBrightness> themeBrightnessGenerator() =>
    kiri.constantFrom(ThemeBrightness.values);

kiri.Arbitrary<Natural> naturalIntGenerator() =>
    kiri.integer(min: 0).map(Natural.new);

kiri.Arbitrary<NonBlankString> nonBlankStringGenerator() => kiri
    .string(
      minLength: 1,
      characterSet: kiri.CharacterSet.alphanum(kiri.CharacterEncoding.ascii),
    )
    .map(NonBlankString.new);

kiri.Arbitrary<({DateTime createdAt, DateTime updatedAt})>
createdAndUpdatedAtGenerator() => kiri
    .dateTime()
    .flatMap(
      (createdAtArbitrary) => kiri.combine2(
        kiri.constant(createdAtArbitrary),
        kiri.dateTime(min: createdAtArbitrary),
      ),
    )
    .map((tuple) => (createdAt: tuple.$1, updatedAt: tuple.$2));

kiri.Arbitrary<String?> nullableStringGenerator() => kiri
    .oneOf([kiri.null_(), kiri.string()])
    .map((choice) => choice is String? ? choice : null);

kiri.Arbitrary<Uri?> nullableUriGenerator() => kiri
    .oneOf([kiri.null_(), uriGenerator()])
    .map((p0) => p0 is Uri? ? p0 : null);

kiri.Arbitrary<Uri> uriGenerator() => kiri
    .combine2(
      kiri.string(
        minLength: 1,
        characterSet: kiri.CharacterSet.alphanum(kiri.CharacterEncoding.ascii),
      ),
      kiri.string(
        minLength: 1,
        characterSet: kiri.CharacterSet.alphanum(kiri.CharacterEncoding.ascii),
      ),
    )
    .map((tuple) => Uri(scheme: 'https', host: '${tuple.$1}.${tuple.$2}'));
