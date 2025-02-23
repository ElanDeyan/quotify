import 'package:drift/drift.dart';
import 'package:quotes_repository/repositories/quote_entry.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/repositories/tag_entry.dart';

import '../exceptions/database_errors.dart';
import '../extensions/quote_entry_extension.dart';
import '../extensions/tag_entry_extension.dart';
import '../tables/quotes.dart';
import '../tables/tags.dart';
import '../utils/tags_set_to_string_converter.dart';
import '../utils/uri_to_nullable_string_converter.dart';
import 'connection/native_connection.dart';

part 'app_database.g.dart';

/// Database for the tags and quotes.
@DriftDatabase(tables: [Tags, Quotes])
final class AppDatabase extends _$AppDatabase {
  /// Constructs an instance of [AppDatabase] with the given encryption
  /// passphrase.
  ///
  /// The [encryptionPassPhrase] is used to encrypt the database connection.
  ///
  /// Example:
  /// ```dart
  /// final db = AppDatabase('mySecretPassphrase');
  /// ```
  AppDatabase(String encryptionPassPhrase)
      : super(
          connect(encryptionPassPhrase),
        );

  /// Constructor for creating an instance of [AppDatabase] specifically
  /// for testing purposes.
  ///
  /// This constructor accepts a [QueryExecutor] which allows for the use of an
  /// in-memory database or any other type of database suitable for testing.
  ///
  /// Example usage:
  /// ```dart
  /// final executor = NativeDatabase.memory();
  /// final database = AppDatabase.forTesting(executor);
  /// ```
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  /// Retrieves all the tags from the database.
  ///
  /// Returns a [Future] that completes with a list of [TagTable] objects
  /// representing all the tags in the database.
  Future<List<TagTable>> get allTags => select(tags).get();

  Future<List<QuoteTable>> get allQuotes => select(quotes).get();

  Stream<List<QuoteTable>> get watchAllQuotes => select(quotes).watch();

  /// A stream that emits a list of all tags from the `tags` table.
  ///
  /// This stream will automatically update whenever the data in the `tags`
  /// table changes.
  Stream<List<TagTable>> get watchAllTags => select(tags).watch();

  /// Clears all tags from the database.
  ///
  /// This method performs a transaction to delete all rows from the `tags`
  /// table.
  ///
  /// It first retrieves the number of tags before deletion and then
  /// deletes all tags.
  ///
  /// If the number of rows affected by the deletion does not match the number
  /// of tags before deletion, it throws a `DatabaseErrors.notDeletedAllTags`
  /// error.
  ///
  /// Returns a [FutureResult] containing [Null] upon successful completion.
  FutureResult<(), DatabaseErrors> clearAllTags() => Result.guardAsync(
        () => transaction(
          () async {
            final howManyTagsBeforeDelete = (await allTags).length;

            final amountOfRowsAffected = await delete(tags).go();

            if (amountOfRowsAffected != howManyTagsBeforeDelete) {
              throw DatabaseErrors.notDeletedAllTags;
            }
            return ();
          },
        ),
      );

  FutureResult<Unit, DatabaseErrors> clearAllQuotes() => Result.guardAsync(
        () => transaction(
          () async {
            final howManyTagsBefore = (await allQuotes).length;

            final amountOfRowsAffected = await delete(quotes).go();

            if (amountOfRowsAffected != howManyTagsBefore) {
              throw DatabaseErrors.notDeletedAllQuotes;
            }

            return ();
          },
        ),
      );

  /// Creates a new tag in the database.
  ///
  /// This method inserts a new tag into the `tags` table. If a tag with the
  /// same label already exists, it will still being added, but with different
  /// ID.
  ///
  /// Returns a [FutureResult] containing the created [TagTable] entry if the
  /// operation is successful, or a [Result.failure] with a
  /// [DatabaseErrors.cannotCreateEntry] error if the operation fails.
  ///
  /// - Parameters:
  ///   - tag: The [TagEntry] object containing the label of the tag to be
  /// created.
  ///
  /// - Returns: A [FutureResult] containing the created [TagTable] entry or an
  /// error.
  FutureResult<TagTable, DatabaseErrors> createTag(TagEntry entry) async {
    final operationResult = await Result.guardAsync<TagTable, DatabaseErrors>(
      () => transaction(
        () async {
          final tagTableOrNull = await into(tags).insertReturningOrNull(
            entry.toTagsCompanion(),
            mode: InsertMode.insertOrIgnore,
          );

          if (tagTableOrNull == null) throw DatabaseErrors.cannotCreateEntry;

          return tagTableOrNull;
        },
      ),
    );

    return switch (operationResult) {
      Ok(:final value) => Result.ok(value),
      Failure(:final failure, :final stackTrace) =>
        Result.failure(failure, stackTrace),
    };
  }

  FutureResult<QuoteTable, DatabaseErrors> createQuote(QuoteEntry entry) async {
    final operationResult = await Result.guardAsync<QuoteTable, DatabaseErrors>(
      () => transaction(
        () async {
          final quoteTableOrNull = await into(quotes).insertReturningOrNull(
            entry.toQuotesCompanion(),
            mode: InsertMode.insertOrIgnore,
          );

          if (quoteTableOrNull == null) throw DatabaseErrors.cannotCreateEntry;

          return quoteTableOrNull;
        },
      ),
    );

    return switch (operationResult) {
      Ok(:final value) => Result.ok(value),
      Failure(:final failure, :final stackTrace) =>
        Result.failure(failure, stackTrace),
    };
  }

  /// Deletes a tag from the database based on the provided [id].
  ///
  /// This method performs a transaction to delete a tag from the `tags` table
  /// where the tag's ID matches the provided [id]. It returns a [FutureResult]
  /// containing the deleted tag if the operation is successful.
  ///
  /// Throws:
  /// - [DatabaseErrors.notFoundId] if no tag with the specified ID is found.
  /// - [DatabaseErrors.tooMuchRowsAffected] if more than one row is affected
  /// by the delete operation.
  ///
  /// Returns:
  /// - A [FutureResult] containing the deleted [TagTable] if the operation is
  /// successful.
  FutureResult<TagTable, DatabaseErrors> deleteTag(Id id) => Result.guardAsync(
        () => transaction(
          () async {
            final affectedRows = await (delete(tags)
                  ..where(
                    (tbl) => tbl.id.equals(id.toInt()),
                  ))
                .goAndReturn();

            return switch (affectedRows) {
              [final deletedTag] => deletedTag,
              [] => throw DatabaseErrors.notFoundId,
              [...] => throw DatabaseErrors.tooMuchRowsAffected,
            };
          },
        ),
      );

  FutureResult<QuoteTable, DatabaseErrors> deleteQuote(Id id) =>
      Result.guardAsync(
        () => transaction(
          () async {
            final affectedRows = await (delete(quotes)
                  ..where(
                    (tbl) => tbl.id.equals(id.toInt()),
                  ))
                .goAndReturn();

            return switch (affectedRows) {
              [final deletedTag] => deletedTag,
              [] => throw DatabaseErrors.notFoundId,
              [...] => throw DatabaseErrors.tooMuchRowsAffected,
            };
          },
        ),
      );

  /// Retrieves a tag from the database by its ID.
  ///
  /// This method performs a query on the `tags` table to find a tag
  /// with the specified [id]. If a tag with the given ID is found,
  /// it returns a [TagTable] containing the tag. If no tag
  /// is found, it returns `null`.
  ///
  /// [id] - The ID of the tag to retrieve.
  ///
  /// Returns a [Future] that completes with a [Maybe] of [TagTable] if
  /// a tag with the specified ID is found, or `null` if no such tag
  /// exists.
  Future<TagTable?> getTagById(Id id) => (select(tags)
        ..where(
          (tbl) => tbl.id.equals(id.toInt()),
        ))
      .getSingleOrNull();

  Future<QuoteTable?> getQuoteById(Id id) => (select(quotes)
        ..where(
          (tbl) => tbl.id.equals(id.toInt()),
        ))
      .getSingleOrNull();

  Future<Set<QuoteTable>> getQuotesWithTagId(Id id) async {
    final quotes = await allQuotes;

    return {
      for (final quote in quotes)
        if (quote.tags
            .map(
              (e) => e.id,
            )
            .contains(id))
          quote,
    };
  }

  /// Retrieves a set of `TagTable` entries corresponding to the provided IDs.
  ///
  /// This method takes an iterable of IDs and returns a set of `TagTable`
  /// objects that match those IDs. If the provided iterable is empty, an
  /// empty set is returned.
  ///
  /// The method iterates over each ID, fetches the corresponding `TagTable`
  /// entry using `getTagById`, and adds it to the set if it exists.
  ///
  /// - Parameter ids: An iterable collection of IDs to fetch `TagTable`
  /// entries for.
  /// - Returns: A `Future` that completes with a set of `TagTable` entries.
  Future<Set<TagTable>> getTagsWithIds(Iterable<Id> ids) async {
    if (ids.isEmpty) return const {};

    final foundTags = <TagTable>{};

    for (final id in ids) {
      final maybeTag = await getTagById(id);
      if (maybeTag != null) foundTags.add(maybeTag);
    }

    return foundTags;
  }

  Future<Set<QuoteTable>> getQuotesWithIds(Iterable<Id> ids) async {
    if (ids.isEmpty) return const {};

    final foundQuotes = <QuoteTable>{};

    for (final id in ids) {
      final quoteOrNull = await getQuoteById(id);
      if (quoteOrNull != null) foundQuotes.add(quoteOrNull);
    }

    return foundQuotes;
  }

  /// Updates a tag in the database with the given [updatedTagEntry].
  ///
  /// This method performs a transaction to update the tag's label and
  /// updatedAt fields. It returns a [FutureResult] containing the updated
  /// [TagTable] entry.
  ///
  /// If the update is successful and exactly one row is affected, the updated
  /// row is returned. If no rows are affected, a [DatabaseErrors.notFoundId]
  /// error is thrown. If more than one row is affected, a
  /// [DatabaseErrors.tooMuchRowsAffected] error is thrown.
  ///
  /// - Parameters:
  ///   - id: The ID of the tag to be updated.
  ///   - updatedTagEntry: The new values for the tag entry.
  ///
  /// - Returns: A [FutureResult] containing the updated [TagTable] entry.
  FutureResult<TagTable, DatabaseErrors> updateTag(
    FullTagEntry updatedTagEntry,
  ) =>
      Result.guardAsync(
        () => transaction(
          () async {
            final affectedRows = await (update(tags)
                  ..where(
                    (tbl) => tbl.id.equals(updatedTagEntry.id.toInt()),
                  ))
                .writeReturning(
              TagsCompanion(
                label: Value(updatedTagEntry.label),
                updatedAt: Value(DateTime.now()),
              ),
            );

            return switch (affectedRows) {
              [final updatedRow] => updatedRow,
              [] => throw DatabaseErrors.notFoundId,
              [...] => throw DatabaseErrors.tooMuchRowsAffected,
            };
          },
        ),
      );

  FutureResult<QuoteTable, DatabaseErrors> updateQuote(
    FullQuoteEntry updatedQuoteEntry,
  ) =>
      Result.guardAsync(
        () => transaction(
          () async {
            final affectedRows = await (update(quotes)
                  ..where(
                    (tbl) => tbl.id.equals(updatedQuoteEntry.id.toInt()),
                  ))
                .writeReturning(
              QuotesCompanion(
                content: Value(updatedQuoteEntry.content),
                author: Value(updatedQuoteEntry.author),
                isFavorite: Value(updatedQuoteEntry.isFavorite),
                source: Value(updatedQuoteEntry.source),
                sourceUri: Value(updatedQuoteEntry.sourceUri),
                tags: Value(updatedQuoteEntry.tags),
                updatedAt: Value(DateTime.now()),
              ),
            );

            return switch (affectedRows) {
              [final updatedRow] => updatedRow,
              [] => throw DatabaseErrors.notFoundId,
              [...] => throw DatabaseErrors.tooMuchRowsAffected,
            };
          },
        ),
      );
}
