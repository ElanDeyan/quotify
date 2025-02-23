/// Extension type for passwords composed by [String] with [String.length] >= 8.
extension type const Min8LengthPassword._(String _self)
    implements String, Object {
  /// Extension type for passwords composed by [String] with [String.length] >=
  /// 8.
  const Min8LengthPassword(this._self)
    : assert(_self.length >= 8, 'Should have at least 8 character length');
}
