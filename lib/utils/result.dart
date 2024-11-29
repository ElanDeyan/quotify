/// Copied from https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart
/// with subtle differences:
/// - Type parameter in asError getter.
/// - Result factories translated to const factories.
library;

// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
/// Utility class to wrap result data
///
///
/// Evaluate the result using a switch statement:
/// ```dart
/// switch (result) {
///   case Ok(): {
///     print(result.value);
///   }
///   case Error(): {
///     print(result.error);
///   }
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Creates an instance of Result containing a value
  const factory Result.ok(T value) = Ok;

  /// Create an instance of Result containing an error
  const factory Result.error(Exception error) = Error;

  /// Convenience method to cast to Ok
  Ok<T> get asOk => this as Ok<T>;

  /// Convenience method to cast to Error
  Error<T> get asError => this as Error<T>;
}

/// Subclass of Result for values
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  /// Returned value in result
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
final class Error<T> extends Result<T> {
  const Error(this.error);

  /// Returned error in result
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
