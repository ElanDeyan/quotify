import 'package:drift/drift.dart';
import 'package:drift_database_service/src/database/connection/native_connection.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/repositories/tag_entry.dart';

import '../tables/tags.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tags])
final class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionPassPhrase)
      : super(
          connect(encryptionPassPhrase),
        );

  @override
  int get schemaVersion => 1;

  Future<List<TagTable>> get allTags => throw UnimplementedError();

  Future<void> clearAllTags() {
    // TODO: implement clearAllTags
    throw UnimplementedError();
  }

  FutureResult<TagTable> createTag(TagEntry tag) {
    // TODO: implement createTag
    throw UnimplementedError();
  }

  FutureResult<TagTable> deleteTag(Id id) {
    // TODO: implement deleteTag
    throw UnimplementedError();
  }

  Future<Maybe<TagTable>?> getTagById(Id id) {
    // TODO: implement getTagById
    throw UnimplementedError();
  }

  Future<List<TagTable>> getTagsByIds(Iterable<Id> ids) {
    // TODO: implement getTagsByIds
    throw UnimplementedError();
  }

  Future<void> restoreTags(List<Tag> tags) {
    // TODO: implement restoreTags
    throw UnimplementedError();
  }

  FutureResult<TagTable> updateTag(TagEntry tag) {
    // TODO: implement updateTag
    throw UnimplementedError();
  }
}
