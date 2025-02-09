/// A [String] that cannot be empty or blank.
extension type const NonBlankString._(String _self) implements String, Object {
  /// A [String] that cannot be empty or blank.
  NonBlankString(this._self)
      : assert(_self.trim().isNotEmpty, 'Cannot be empty or blank');
}
