extension type const Min8LengthPassword._(String _self)
    implements String, Object {
  const Min8LengthPassword(this._self)
      : assert(_self.length >= 8, 'Should have at least 8 character length');
}
