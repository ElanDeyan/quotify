/// A sealed class representing an optional value of type [T].
/// 
/// This class has two possible states:
/// - [Some]: Represents a value of type [T].
/// - [None]: Represents the absence of a value.
sealed class Option<T extends Object> {
  /// Creates an instance of [Option].
  const Option();

  /// Creates an instance of [Some] with the given [value].
  const factory Option.some(T value) = Some;

  /// Creates an instance of [None].
  const factory Option.none() = None;
}

/// A class representing a value of type [T].
/// 
/// This class is a subtype of [Option] and indicates that a value is present.
final class Some<T extends Object> extends Option<T> {
  /// Creates an instance of [Some] with the given [value].
  const Some(this.value);

  /// The value of type [T].
  final T value;
}

/// A class representing the absence of a value.
/// 
/// This class is a subtype of [Option] and indicates that no value is present.
final class None<T extends Object> extends Option<T> {
  /// Creates an instance of [None].
  const None();
}
