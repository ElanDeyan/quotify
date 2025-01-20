import 'package:drift_database_service/drift_database_service.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';

import '../logic/models/tag.dart';
import 'tag_entry.dart';

/// An abstract interface class that defines the contract for a repository
/// that manages tags.
///
/// This repository provides methods to perform CRUD operations on tags,
/// as well as methods to retrieve tags by their IDs and restore or clear
/// all tags.
abstract interface class TagRepository {
  /// Retrieves all tags.
  ///
  /// Returns a [Future] that completes with an unmodifiable list of all
  /// [Tag] objects.
  Future<List<Tag>> get allTags;

  /// Retrieves a tag by its ID.
  ///
  /// [id] - The ID of the tag to retrieve.
  ///
  /// Returns a [Future] that completes with the [Tag] object if found,
  /// or `null` if no tag with the given ID exists.
  Future<Tag?> getTagById(Id id);

  /// Retrieves multiple tags by their IDs.
  ///
  /// [ids] - An iterable of IDs of the tags to retrieve.
  ///
  /// Returns a [Future] that completes with an unmodifiable list of
  /// [Tag] objects corresponding to the given IDs.
  Future<List<Tag>> getTagsByIds(Iterable<Id> ids);

  /// Creates a new tag.
  ///
  /// [tag] - The [TagEntry] object containing the details of the tag to create.
  ///
  /// Returns a [FutureResult] that completes with the created [Tag] object.
  FutureResult<Tag, DatabaseErrors> createTag(TagEntry tag);

  /// Updates an existing tag.
  ///
  /// [tag] - The [TagEntry] object containing the updated details of the tag.
  ///
  /// Returns a [FutureResult] that completes with the updated [Tag] object.
  FutureResult<Tag, DatabaseErrors> updateTag(FullTagEntry tag);

  /// Deletes a tag by its ID.
  ///
  /// [id] - The ID of the tag to delete.
  ///
  /// Returns a [FutureResult] that completes with the deleted [Tag] object.
  FutureResult<Tag, DatabaseErrors> deleteTag(Id id);

  /// Clears all tags.
  ///
  /// Returns a [Future] that completes when all tags have been cleared.
  FutureResult<(), DatabaseErrors> clearAllTags();
}
