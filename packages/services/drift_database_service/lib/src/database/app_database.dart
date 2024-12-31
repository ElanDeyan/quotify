import 'package:drift/drift.dart';
import 'package:drift_database_service/src/database/connection/native_connection.dart';
import 'package:drift_database_service/src/exceptions/database_errors.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/repositories/tag_entry.dart';

import '../tables/tags.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tags])
final class AppDatabase extends _$AppDatabase {
  /// Constructs an instance of [AppDatabase] with the given encryption passphrase.
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
  int get schemaVersion => 1;

  /// Retrieves all the tags from the database.
  ///
  /// Returns a [Future] that completes with a list of [TagTable] objects
  /// representing all the tags in the database.
  Future<List<TagTable>> get allTags => select(tags).get();

  /// A stream that emits a list of all tags from the `tags` table.
  ///
  /// This stream will automatically update whenever the data in the `tags`
  /// table changes.
  Stream<List<TagTable>> get allTagsStream => select(tags).watch();

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
  /// Returns a [FutureResult] containing [Unit] upon successful completion.
  FutureResult<void> clearAllTags() => Result.fromComputationAsync(
        () => transaction(
          () async {
            final howManyTagsBeforeDelete = (await allTags).length;

            final amountOfRowsAffected = await delete(tags).go();

            if (amountOfRowsAffected != howManyTagsBeforeDelete) {
              throw DatabaseErrors.notDeletedAllTags;
            }
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
  FutureResult<TagTable> createTag(TagEntry tag) async {
    final operation = await into(tags).insertReturningOrNull(
      TagsCompanion(label: Value(tag.label)),
      mode: InsertMode.insertOrReplace,
    );

    if (operation == null) {
      return Result.failure(
        DatabaseErrors.cannotCreateEntry,
        StackTrace.current,
      );
    }

    return Result.ok(operation);
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
  FutureResult<TagTable> deleteTag(Id id) async => Result.fromComputationAsync(
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
  Future<TagTable?> getTagById(Id id) async => (select(tags)
        ..where(
          (tbl) => tbl.id.equals(id.toInt()),
        ))
      .getSingleOrNull();

  Future<List<TagTable>> getTagsByIds(Iterable<Id> ids) {
    // TODO: implement getTagsByIds
    throw UnimplementedError();
  }

  Future<void> restoreTags(List<Tag> tags) {
    // TODO: implement restoreTags
    throw UnimplementedError();
  }

  /// Updates a tag in the database with the given [id] and [updatedTagEntry].
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
  FutureResult<TagTable> updateTag(Id id, TagEntry updatedTagEntry) async =>
      Result.fromComputationAsync(
        () => transaction(
          () async {
            final affectedRows = await (update(tags)
                  ..where(
                    (tbl) => tbl.id.equals(id.toInt()),
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
}
