import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/serialization/interfaces/encodable.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/logic/models/tag_errors.dart';

import 'quote_errors.dart';

/// A Quote class.
@immutable
final class Quote implements Encodable {
  /// A Quote class.
  const Quote({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    this.source,
    this.sourceUri,
    this.isFavorite = false,
    this.tags = const {},
  });

  /// An [Id].
  final Id id;

  /// The content, the phrase itself.
  final NonBlankString content;

  /// The author of the [Quote].
  final NonBlankString author;

  /// Source of the quote, like a chapter of a book or a movie.
  final String? source;

  /// An accessible [Uri] to be launched.
  final Uri? sourceUri;

  /// If the quote was favorite.
  final bool isFavorite;

  /// [DateTime] creation of the quote.
  final DateTime createdAt;

  /// Last updated [DateTime]. By default it is equal to [createdAt]
  /// when creating.
  final DateTime updatedAt;

  /// [Set] of [Tag]s related to this quote.
  final Set<Tag> tags;

  @override
  bool operator ==(covariant Quote other) =>
      id == other.id &&
      content == other.content &&
      author == other.author &&
      source == other.source &&
      sourceUri == other.sourceUri &&
      isFavorite == other.isFavorite &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      const SetEquality<Tag>().equals(tags, other.tags);

  @override
  int get hashCode => Object.hashAllUnordered([
        id,
        content,
        author,
        source,
        sourceUri,
        isFavorite,
        createdAt,
        updatedAt,
        tags,
      ]);

  /// Copies [Quote] with specified parameters.
  Quote copyWith({
    Id? id,
    NonBlankString? content,
    NonBlankString? author,
    String? source,
    Uri? sourceUri,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Set<Tag>? tags,
  }) =>
      Quote(
        id: id ?? this.id,
        content: content ?? this.content,
        author: author ?? this.author,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isFavorite: isFavorite ?? this.isFavorite,
        source: source ?? this.source,
        sourceUri: sourceUri ?? this.sourceUri,
        tags: tags ?? this.tags,
      );

  @override
  String toJsonString() => jsonEncode(toMap());

  @override
  Map<String, Object?> toMap() => {
        'id': id.toInt(),
        'content': content,
        'author': author,
        'source': source,
        'sourceUri': sourceUri,
        'isFavorite': isFavorite,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'tags': <Map<String, Object?>>[
          for (final tag in tags) tag.toMap(),
        ],
      };

  static Result<Quote> fromMap(Map<String, Object?> map) {
    if (map
        case {
          'id': final int id,
          'content': final String content,
          'author': final String author,
          'source': final String? source,
          'sourceUri': final String? sourceUri,
          'isFavorite': final bool isFavorite,
          'createdAt': final String createdAtString,
          'updatedAt': final String updatedAtString,
          'tags': final List<Object?> tags,
        }
        when !id.isNegative &&
            content.trim().isNotEmpty &&
            author.trim().isNotEmpty &&
            (sourceUri == null || Uri.tryParse(sourceUri) != null) &&
            DateTime.tryParse(createdAtString) != null &&
            DateTime.tryParse(updatedAtString) != null &&
            tags.every((element) => element is Map<String, Object?>)) {
      final createdAtDateTime = DateTime.parse(createdAtString);
      final updatedAtDateTime = DateTime.parse(updatedAtString);

      if (updatedAtDateTime.isBefore(createdAtDateTime)) {
        return Result.failure(
          QuoteErrors.updatedAtDateBeforeCreatedAt,
          StackTrace.current,
        );
      }

      final tagsList = tags.cast<Map<String, Object?>>();

      final tagsSet = <Tag>{};

      for (final tagMap in tagsList) {
        if (Tag.fromMap(tagMap) case Ok(:final value)) {
          tagsSet.add(value);
          continue;
        }
        return Result.failure(
          TagErrors.invalidMapRepresentation,
          StackTrace.current,
        );
      }

      return Result.ok(
        Quote(
          id: Id(id.toNatural()),
          content: NonBlankString(content),
          author: NonBlankString(author),
          source: source,
          sourceUri: sourceUri != null ? Uri.tryParse(sourceUri) : null,
          isFavorite: isFavorite,
          createdAt: createdAtDateTime,
          updatedAt: updatedAtDateTime,
          tags: tagsSet,
        ),
      );
    }

    return Result.failure(
      QuoteErrors.invalidMapRepresentation,
      StackTrace.current,
    );
  }

  static Result<Quote> fromJsonString(String jsonString) {
    late final Object? decodedJson;

    try {
      decodedJson = jsonDecode(jsonString);
    } on FormatException catch (e, stackTrace) {
      return Result.failure(QuoteErrors.invalidJsonString, stackTrace);
    }

    if (decodedJson case final Map<String, Object?> map) {
      return fromMap(map);
    }

    return Result.failure(QuoteErrors.invalidJsonString, StackTrace.current);
  }
}
