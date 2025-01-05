import 'package:drift_database_service/drift_database_service.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/tag.dart';
import 'tag_entry.dart';
import 'tag_repository.dart';
import 'tag_table_extension.dart';

/// Repository for operations related to [Tag]s.
final class TagRepositoryImpl implements TagRepository {
  /// Repository for operations related to [Tag]s.
  const TagRepositoryImpl({required this.database});

  /// Instance of [AppDatabase] to operate with Drift database.
  final AppDatabase database;

  @override
  Future<List<Tag>> get allTags async => List.unmodifiable(
        (await database.allTags).map(
          (e) => e.toTag(),
        ),
      );

  @override
  FutureResult<void> clearAllTags() => database.clearAllTags();

  @override
  FutureResult<Tag> createTag(TagEntry tag) async =>
      switch (await database.createTag(tag)) {
        Ok(:final value) => Result.ok(value.toTag()),
        Failure(:final failure, :final stackTrace) =>
          Result.failure(failure, stackTrace),
      };

  @override
  FutureResult<Tag> deleteTag(Id id) async =>
      switch (await database.deleteTag(id)) {
        Ok(:final value) => Result.ok(value.toTag()),
        Failure(:final failure, :final stackTrace) =>
          Result.failure(failure, stackTrace),
      };

  @override
  Future<Tag?> getTagById(Id id) =>
      database.getTagById(id).then((value) => value?.toTag());

  @override
  Future<List<Tag>> getTagsByIds(Iterable<Id> ids) async => List.unmodifiable(
        (await database.getTagsWithIds(ids)).map(
          (e) => e.toTag(),
        ),
      );

  @override
  FutureResult<Tag> updateTag(FullTagEntry tag) async =>
      switch (await database.updateTag(tag)) {
        Ok(:final value) => Result.ok(value.toTag()),
        Failure(:final failure, :final stackTrace) =>
          Result.failure(failure, stackTrace),
      };
}
