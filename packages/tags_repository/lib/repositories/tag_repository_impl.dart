import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/tag.dart';
import 'tag_entry.dart';
import 'tag_repository.dart';

final class TagRepositoryImpl implements TagRepository {
  @override
  // TODO: implement allTags
  Future<List<Tag>> get allTags => throw UnimplementedError();

  @override
  Future<void> clearAllTags() {
    // TODO: implement clearAllTags
    throw UnimplementedError();
  }

  @override
  FutureResult<Tag> createTag(TagEntry tag) {
    // TODO: implement createTag
    throw UnimplementedError();
  }

  @override
  FutureResult<Tag> deleteTag(Id id) {
    // TODO: implement deleteTag
    throw UnimplementedError();
  }

  @override
  Future<Maybe<Tag>?> getTagById(Id id) {
    // TODO: implement getTagById
    throw UnimplementedError();
  }

  @override
  Future<List<Tag>> getTagsByIds(Iterable<Id> ids) {
    // TODO: implement getTagsByIds
    throw UnimplementedError();
  }

  @override
  Future<void> restoreTags(List<Tag> tags) {
    // TODO: implement restoreTags
    throw UnimplementedError();
  }

  @override
  FutureResult<Tag> updateTag(TagEntry tag) {
    // TODO: implement updateTag
    throw UnimplementedError();
  }
}
