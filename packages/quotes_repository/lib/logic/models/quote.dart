import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:quotify_utils/serialization/interfaces/encodable.dart';
import 'package:tags_repository/logic/models/tag.dart';
import 'package:tags_repository/logic/models/tag_model_errors.dart';

import 'quote_model_errors.dart';

/// A Quote class.
@immutable
final class Quote implements Encodable, Queryable {
  /// A Quote class.
  Quote({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    this.source,
    this.sourceUri,
    this.isFavorite = false,
    this.tags = const {},
  }) : assert(
          !updatedAt.isBefore(createdAt),
          'Updated at should be equal or after createdAt',
        );

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
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': <Map<String, Object?>>[
          for (final tag in tags) tag.toMap(),
        ],
      };

  /// Creates a `Quote` object from a map representation.
  ///
  /// The map must contain the following keys with corresponding value types:
  /// - 'id': `int` (non-negative)
  /// - 'content': `String` (non-empty)
  /// - 'author': `String` (non-empty)
  /// - 'source': `String?` (optional)
  /// - 'sourceUri': `String?` (optional, must be a valid URI if present)
  /// - 'isFavorite': `bool`
  /// - 'createdAt': `String` (must be a valid date-time string)
  /// - 'updatedAt': `String` (must be a valid date-time string)
  /// - 'tags': `List<Object?>` (each element must be a map)
  ///
  /// Returns a `Result<Quote>` which is either:
  /// - `Result.ok(Quote)` if the map is valid and the `Quote` object is
  /// created successfully.
  /// - `Result.failure` with appropriate error if the map is invalid or any
  /// validation fails.
  ///
  /// Possible errors:
  /// - `QuoteErrors.invalidMapRepresentation`: If the map does not meet the
  /// required structure or contains invalid data.
  /// - `QuoteErrors.updatedAtDateBeforeCreatedAt`: If the `updatedAt` date
  /// is before the `createdAt` date.
  /// - `TagErrors.invalidMapRepresentation`: If any tag map is invalid.
  static Result<Quote, Exception> fromMap(Map<String, Object?> map) {
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
          QuoteModelErrors.updatedAtDateBeforeCreatedAt,
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
          TagModelErrors.invalidMapRepresentation,
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
      QuoteModelErrors.invalidMapRepresentation,
      StackTrace.current,
    );
  }

  /// Converts a JSON string into a `Quote` object.
  ///
  /// This method attempts to decode the provided JSON string and convert it
  /// into a `Quote` object. If the decoding or conversion fails, it returns a
  /// `Result.failure` with the appropriate error and stack trace.
  ///
  /// - Parameter jsonString: The JSON string to be converted.
  /// - Returns: A `Result` containing either a `Quote` object or a failure with
  ///   an error and stack trace.
  static Result<Quote, Exception> fromJsonString(String jsonString) {
    late final Object? decodedJson;

    try {
      decodedJson = jsonDecode(jsonString);
    } on FormatException catch (_, stackTrace) {
      return Result.failure(QuoteModelErrors.invalidJsonString, stackTrace);
    }

    if (decodedJson case final Map<String, Object?> map) {
      return fromMap(map);
    }

    return Result.failure(
      QuoteModelErrors.invalidJsonString,
      StackTrace.current,
    );
  }

  @override
  String get asQueryableString {
    final buffer = StringBuffer()
      ..writeAll(
        [
          content,
          author,
          if (source != null) source,
          if (sourceUri != null) sourceUri.toString(),
          ...tags.map(
            (e) => e.label,
          ),
        ],
        '\n',
      );

    return buffer.toString();
  }

  @override
  bool hasMatchWith(
    String string, {
    bool caseSensitive = false,
    bool multiline = true,
    bool dotAll = false,
    bool unicode = false,
  }) =>
      RegExp(
        string,
        multiLine: multiline,
        unicode: unicode,
        dotAll: dotAll,
        caseSensitive: caseSensitive,
      ).hasMatch(asQueryableString);

  /// Key for using in serialization of quotes.
  static const listOfQuotesJsonKey = 'quotes';
}
