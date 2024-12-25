import 'package:meta/meta.dart';

import 'natural.dart';

/// An extension type that wraps a `Natural` value and provides additional functionality.
///
/// The `Id` extension type allows you to convert the wrapped `Natural` value to an `int`.
///
/// Example usage:
/// ```dart
/// Natural naturalValue = Natural(42);
/// Id id = Id(naturalValue);
/// int intValue = id.toInt();
/// ```
///
/// Properties:
/// - `_self`: The wrapped `Natural` value.
///
/// Methods:
/// - `toInt()`: Converts the wrapped `Natural` value to an `int`.
@immutable
extension type const Id(Natural _self) {
  /// Converts to [int].
  int toInt() => _self;
}
