/// Extension type for passwords composed by [String] with [String.length] >= 8.
extension type const BackupPassword._(String _self) implements String, Object {
  /// Extension type for passwords composed by [String] with [String.length] >=
  /// 8.
  BackupPassword(this._self)
    : assert(_self.length >= 8, 'Should have at least 8 character length'),
      assert(_self.contains(RegExp('[A-Z]')), 'Should have uppercase letters'),
      assert(
        _self.contains(RegExp('[a-z]')),
        'Should contain lowercase letters',
      ),
      assert(
        _self.contains(RegExp('[0-9]')),
        'Should contain at least one number',
      ),
      assert(
        _self.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')),
        'Should contain at least one special character, emoji not included',
      );
}
