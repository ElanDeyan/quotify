import 'package:drift/drift.dart';

import '../mixins/created_at_and_updated_at_mixin.dart';
import '../mixins/int_id_primary_key_mixin.dart';
import '../utils/tags_set_to_string_converter.dart';
import '../utils/uri_to_nullable_string_converter.dart';

@DataClassName('QuoteTable')
/// Represents the Quotes table in the database.
///
/// This table contains the following columns:
/// - `id`: The unique identifier for each quote.
/// - `text`: The text content of the quote.
/// - `author`: The author of the quote.
/// - `createdAt`: The timestamp when the quote was created.
base class Quotes extends Table
    with IntIdPrimaryKeyMixin, CreatedAtAndUpdatedAtMixin {
  late final Column<String> content =
      text().check(content.length.isBiggerThanValue(0))();

  late final Column<String> author =
      text().check(author.length.isBiggerThanValue(0))();

  late final Column<String> source = text().nullable()();

  late final Column<String> sourceUri =
      text().nullable().map(const UriToNullableStringConverter())();

  late final Column<bool> isFavorite = boolean()();

  late final Column<String> tags =
      text().map(const TagsSetToStringConverter())();

  @override
  bool get isStrict => true;
}
