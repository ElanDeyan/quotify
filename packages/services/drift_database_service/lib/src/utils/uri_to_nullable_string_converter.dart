import 'package:drift/drift.dart';

/// A custom [TypeConverter] that converts between [Uri] and [String] types.
///
/// This converter is used to handle nullable [Uri] and [String] values,
/// allowing them to be stored in and retrieved from a database.
///
/// Example usage:
/// ```dart
/// final converter = UriToNullableStringConverter();
/// final uri = Uri.parse('https://example.com');
/// final string = converter.toSql(uri); // Converts Uri to String
/// final restoredUri = converter.fromSql(string); // Converts String back to Uri
/// ```
///
/// This class extends the [TypeConverter] class provided by the Drift package.
final class UriToNullableStringConverter extends TypeConverter<Uri?, String?> {
  /// A custom [TypeConverter] that converts between [Uri] and [String] types.
  ///
  /// This converter is used to handle nullable [Uri] and [String] values,
  /// allowing them to be stored in and retrieved from a database.
  ///
  /// Example usage:
  /// ```dart
  /// final converter = UriToNullableStringConverter();
  /// final uri = Uri.parse('https://example.com');
  /// final string = converter.toSql(uri); // Converts Uri to String
  /// final restoredUri = converter.fromSql(string); // Converts String back to Uri
  /// ```
  ///
  /// This class extends the [TypeConverter] class provided by the Drift
  /// package.
  const UriToNullableStringConverter();
  @override
  Uri? fromSql(String? fromDb) {
    if (fromDb?.trim().isEmpty ?? true) return null;

    return Uri.tryParse(fromDb!);
  }

  @override
  String? toSql(Uri? value) {
    if (value == null) return null;

    return value.toString();
  }
}
