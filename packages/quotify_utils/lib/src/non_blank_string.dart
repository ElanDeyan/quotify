import 'package:meta/meta.dart';

/// A [String] that cannot be empty or blank.
@immutable
extension type const NonBlankString._(String _self) implements String {
  /// A [String] that cannot be empty or blank.
  factory NonBlankString(String string) {
    assert(string.trim().isNotEmpty, 'Cannot be empty or blank');
    if (string.trim().isEmpty) {
      throw ArgumentError.value(string, 'string', 'Cannot be empty or blank');
    }
    return NonBlankString._(string);
  }
}
