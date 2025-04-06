/// Interface for making classes queryable.
abstract interface class Queryable {
  /// Converts this to a string that will be used with [hasMatchWith] method.
  String get asQueryableString;

  /// Matches [asQueryableString] with [string] using [RegExp].
  bool hasMatchWith(
    String string, {
    bool caseSensitive = false,
    bool multiline = true,
    bool dotAll = false,
    bool unicode = false,
  }) => RegExp(
    string,
    caseSensitive: caseSensitive,
    dotAll: dotAll,
    multiLine: multiline,
    unicode: unicode,
  ).hasMatch(asQueryableString);
}
