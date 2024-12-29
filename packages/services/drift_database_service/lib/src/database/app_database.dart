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

  Future<void> clearAllTags() {
    // TODO: implement clearAllTags
    throw UnimplementedError();
  }

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

  FutureResult<TagTable> deleteTag(Id id) {
    // TODO: implement deleteTag
    throw UnimplementedError();
  }

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
  Future<Maybe<TagTable>?> getTagById(Id id) async => (select(tags)
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
  /// This method performs a database transaction to update the tag's label and
  /// updatedAt fields. If the update affects exactly one row, it retrieves the
  /// updated tag from the database and returns it. If no rows are affected or
  /// the updated tag cannot be found, it throws a [DatabaseErrors] exception.
  ///
  /// Returns a [FutureResult] containing the updated [TagTable].
  ///
  /// Throws:
  /// - [DatabaseErrors.cannotUpdateEntry] if the update does not affect
  /// exactly one row.
  /// - [DatabaseErrors.notFoundId] if the updated tag cannot be found.
  FutureResult<TagTable> updateTag(Id id, TagEntry updatedTagEntry) async =>
      Result.fromComputationAsync(
        () => transaction(
          () async {
            final affectedRows = await (update(tags)
                  ..where(
                    (tbl) => tbl.id.equals(id.toInt()),
                  ))
                .write(
              TagsCompanion(
                label: Value(updatedTagEntry.label),
                updatedAt: Value(DateTime.now()),
              ),
            );

            if (affectedRows != 1) throw DatabaseErrors.cannotUpdateEntry;

            final updatedTag = await getTagById(id);
            if (updatedTag == null) {
              throw DatabaseErrors.notFoundId;
            }

            return updatedTag;
          },
        ),
      );
}
