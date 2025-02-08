/// Extension methods similar to Kotlin scope functions.
///
/// Some functions are not available:
///
/// - with: since the [let] function here enables changes in self, with is not
/// necessary.
/// - run (as extension): same reason of with.
/// - apply: cascade operations already does what the Kotlin's apply method
/// does.
extension ScopeFunctions<T extends Object> on T {
  /// Calls the specified function [callback] with `this` value as its argument
  /// and returns the result.
  ///
  /// Example:
  /// ```dart
  /// final result = 'Hello'.let((it) => it.length); // result is 5
  /// ```
  R let<R extends Object?>(R Function(T self) callback) => callback(this);

  /// Calls the specified function [callback] with `this` value as its argument
  /// and returns `this` value.
  ///
  /// Example:
  /// ```dart
  /// final result = 'Hello'.also((it) => print(it)); // prints 'Hello' and result is 'Hello'
  /// ```
  T also(void Function(T self) callback) {
    try {
      return this;
    } finally {
      callback(this);
    }
  }

  /// Returns `this` value if it matches the given [predicate],
  /// otherwise returns `null`.
  ///
  /// Example:
  /// ```dart
  /// final result = 'Hello'.takeIf((it) => it.length > 3); // result is 'Hello'
  /// final result2 = 'Hi'.takeIf((it) => it.length > 3); // result is null
  /// ```
  T? takeIf(bool Function(T self) predicate) => predicate(this) ? this : null;

  /// Returns `this` value if it does not match the given [predicate],
  /// otherwise returns `null`.
  ///
  /// Example:
  /// ```dart
  /// final result = 'Hello'.takeUnless((it) => it.length > 3); // result is null
  /// final result2 = 'Hi'.takeUnless((it) => it.length > 3); // result is 'Hi'
  /// ```
  T? takeUnless(bool Function(T self) predicate) =>
      !predicate(this) ? this : null;
}
