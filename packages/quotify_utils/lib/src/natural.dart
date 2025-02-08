import 'package:meta/meta.dart';

/// An [int] extension for >= 0 integers.
@immutable
extension type const Natural._(int _self) implements int {
  /// An [int] extension for >= 0 integers.
  factory Natural(int integer) {
    assert(integer >= 0, 'Integer should be higher than zero');
    return Natural._(integer);
  }
}

/// Extension on [int] to convert an integer to a [Natural] number.
extension IntNatural on int {
  /// Converts an integer to a [Natural] number.
  ///
  /// Returns a [Natural] instance representing the current integer.
  Natural toNatural() => Natural(this);
}
