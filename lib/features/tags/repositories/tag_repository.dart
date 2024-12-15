import 'package:quotify_utils/quotify_utils.dart';

import '../../core/id.dart';
import '../logic/models/tag.dart';
import 'tag_entry.dart';

/// Interface for [Tag]s operations.
abstract interface class TagRepository {
  Future<List<Tag>> get allTags;

  Future<Tag?> getTagById(Id id);

  Future<List<Tag>> getTagsByIds(Iterable<Id> ids);

  FutureResult<Tag> createTag(TagEntry tag);

  FutureResult<Tag> updateTag(TagEntry tag);

  FutureResult<Tag> deleteTag(Id id);

  Future<void> restoreTags(List<Tag> tags);

  Future<void> clearAllTags();
}
