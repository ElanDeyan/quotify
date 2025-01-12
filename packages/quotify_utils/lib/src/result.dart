/// Copied from https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart
/// with subtle differences:
/// - Renames [Error] to [Failure].
/// - Type parameter in [Result.asFailure] getter.
/// - [Result] factories translated to const factories.
/// - [StackTrace] class inside the [Failure].
/// - Also some comments.
library;

import 'package:meta/meta.dart';

import '../quotify_utils.dart';

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
sealed class Result<T extends Object?> {
  const Result();

  /// Creates an instance of Result containing a value
  const factory Result.ok(T value) = Ok;

  /// Create an instance of Result containing an error
  const factory Result.failure(Exception failure, StackTrace stackTrace) =
      Failure;

  /// Returns a [Result] from a synchronous function call.
  factory Result.guardSync(T Function() computation) {
    try {
      return Result.ok(computation());
    } on Exception catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }

  /// Returns a [Result] from a synchronous function call.
  static FutureResult<T> guardAsync<T extends Object?>(
    Future<T> Function() computation,
  ) async {
    try {
      final result = await computation();
      return Result.ok(result);
    } on Exception catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }

  /// Unwraps the result, returning the value if it is an `Ok` instance,
  /// or throwing the failure if it is a `Failure` instance.
  ///
  /// Throws:
  /// - The failure contained in the `Failure` instance.
  T unwrap() => switch (this) {
        Ok(:final value) => value,
        Failure(:final failure, stackTrace: _) => throw failure,
      };

  /// Transforms the current `Result` into another `Result` by applying the
  /// given callback function to the value if the current `Result` is `Ok`.
  ///
  /// If the current `Result` is `Failure`, it returns a new `Result` with the
  /// same failure and stack trace.
  ///
  /// The callback function takes the value of type `T` and returns a `Result`
  /// of type `U`.
  ///
  /// - Parameter callback: A function that takes a value of type `T` and
  ///   returns a `Result` of type `U`.
  ///
  /// - Returns: A `Result` of type `U` which is the result of applying the
  ///   callback function to the value if the current `Result` is `Ok`, or a
  ///   `Result` with the same failure and stack trace if the current `Result`
  ///   is `Failure`.
  Result<U> flatMapSync<U extends Object?>(U Function(T value) callback) =>
      switch (this) {
        Ok(:final value) => Result.guardSync(() => callback(value)),
        Failure(:final failure, :final stackTrace) =>
          Result.failure(failure, stackTrace),
      };

  /// Transforms the current `Result` into a `FutureResult` by applying
  /// an asynchronous callback function to the value if the result is `Ok`.
  ///
  /// If the result is `Ok`, the callback function is invoked with the value,
  /// and the result of the callback is wrapped in a `FutureResult` using
  /// `Result.guardAsync`. If the result is `Failure`, the failure and
  /// stack trace are propagated.
  ///
  /// Type Parameters:
  /// - `U`: The type of the value in the resulting `FutureResult`.
  ///
  /// Parameters:
  /// - `callback`: A function that takes the value of type `T` and returns a
  /// `Future` of type `U`.
  ///
  /// Returns:
  /// A `FutureResult` containing the result of the callback function if the
  /// original result is `Ok`, or the original failure and stack trace if the
  /// result is `Failure`.
  FutureResult<U> flatMapAsync<U extends Object?>(
    Future<U> Function(T value) callback,
  ) async =>
      switch (this) {
        Ok(:final value) => Result.guardAsync(() => callback(value)),
        Failure(:final failure, :final stackTrace) =>
          Result.failure(failure, stackTrace),
      };

  /// Convenience method to cast to [Ok]
  @visibleForTesting
  Ok<T> get asOk => this as Ok<T>;

  /// Convenience method to cast to [Failure]
  @visibleForTesting
  Failure<T> get asFailure => this as Failure<T>;
}

/// Subclass of Result for values
final class Ok<T extends Object?> extends Result<T> {
  /// Subclass of Result for values
  const Ok(this.value);

  /// Returned value in result
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
final class Failure<T extends Object?> extends Result<T> {
  /// Subclass of Result for errors
  const Failure(this.failure, this.stackTrace);

  /// Returned error in result
  final Exception failure;

  /// Stack trace related to this [Failure].
  final StackTrace stackTrace;

  @override
  String toString() => 'Result<$T>.error(\n\t$failure,\n\t$stackTrace,\n)';
}
