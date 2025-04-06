import 'package:meta/meta.dart';

/// An [int] extension for >= 0 integers.
@immutable
extension type const Natural._(int _self) implements int, Object {
  /// An [int] extension for >= 0 integers.
  const Natural(this._self)
    : assert(_self >= 0, 'Integer should be higher than zero');

  /// Well... zero.
  static const zero = Natural._(0);
}

/// Extension on [int] to convert an integer to a [Natural] number.
extension IntNatural on int {
  /// Converts an integer to a [Natural] number.
  ///
  /// Returns a [Natural] instance representing the current integer.
  Natural toNatural() => Natural(this);
}
