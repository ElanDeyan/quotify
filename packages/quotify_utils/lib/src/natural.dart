/// An [int] extension for >= 0 integers.
extension type Natural._(int _self) implements int {
  /// An [int] extension for >= 0 integers.
  factory Natural(int integer) {
    assert(integer >= 0, 'Integer should be higher than zero');
    return Natural._(integer);
  }
}
