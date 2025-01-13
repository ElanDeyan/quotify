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
        Ok(:final value) => await Result.guardAsync(() => callback(value)),
        Failure(:final failure, :final stackTrace) =>
          Result.failure(failure, stackTrace),
      };

  /// Applies one of two functions to the result, depending on whether it is an
  /// `Ok` or a `Failure`.
  ///
  /// If the result is an `Ok`, the [onOk] function is called with the value.
  /// If the result is a `Failure`, the [onFailure] function is called with the
  /// exception and stack trace.
  ///
  /// The return value of the called function is returned.
  ///
  /// - Parameters:
  ///   - onOk: A function that is called with the value if the result is an
  ///   `Ok`.
  ///   - onFailure: A function that is called with the exception and stack
  ///   trace if the result is a `Failure`.
  /// - Returns: The return value of the called function.
  R fold<R extends Object?>({
    required R Function(T value) onOk,
    required R Function(Exception exception, StackTrace stackTrace) onFailure,
  }) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Failure(:final failure, :final stackTrace) =>
          onFailure(failure, stackTrace),
      };

  /// Returns the value if the result is `Ok`, otherwise returns the provided
  /// fallback value if the result is `Failure`.
  ///
  /// - Parameter fallback: The value to return if the result is `Failure`.
  /// - Returns: The value if the result is `Ok`, otherwise the fallback value.
  T orElse(T fallback) => switch (this) {
        Ok(:final value) => value,
        Failure(failure: _, stackTrace: _) => fallback,
      };

  /// Recovers from a failure by executing the provided synchronous recovery
  /// function.
  ///
  /// If the current `Result` is an `Ok` instance, it returns the current
  /// instance.
  /// If the current `Result` is a `Failure` instance, it executes the
  /// `onFailure` function with the exception and stack trace, and returns a
  /// new `Result` based on the outcome of the `onFailure` function.
  ///
  /// The `onFailure` function is a synchronous function that takes an
  /// `Exception` and a `StackTrace` as parameters and returns a value of type
  /// `T`.
  ///
  /// Example usage:
  /// ```dart
  /// Result<int> result = someFunctionThatReturnsResult();
  /// Result<int> recoveredResult = result.recoverSync((exception, stackTrace) {
  ///   // Handle the exception and return a recovery value
  ///   return 42;
  /// });
  /// ```
  ///
  /// - Parameter onFailure: A synchronous function that takes an `Exception`
  ///   and a `StackTrace` and returns a value of type `T`.
  /// - Returns: A `Result` instance which is either the original `Ok` instance
  ///   or a new `Result` based on the outcome of the `onFailure` function.
  FutureResult<T> recoverAsync(
    Future<T> Function(Exception exception, StackTrace stackTrace) onFailure,
  ) async =>
      switch (this) {
        Ok(value: _) => this,
        Failure(:final failure, :final stackTrace) =>
          await Result.guardAsync(() => onFailure(failure, stackTrace)),
      };

  /// Filters the `Result` based on a predicate function applied to the
  /// `Ok` value.
  ///
  /// If the `Result` is `Ok` and the predicate function returns `false`,
  /// it returns a `Result.failure` with the provided exception and current
  /// stack trace. Otherwise, it returns the original `Result`.
  ///
  /// - Parameters:
  ///   - predicateOnOk: A function that takes the `Ok` value and returns a
  ///   `bool`.
  ///   - exceptionOnFalse: The exception to return if the predicate function
  ///   returns `false`.
  ///
  /// - Returns: A `Result` that is either the original `Result` or a
  ///   `Result.failure` if the predicate function returns `false`.
  Result<T> where(
    bool Function(T value) predicateOnOk,
    Exception exceptionOnFalse,
  ) =>
      switch (this) {
        Ok(:final value) when !predicateOnOk(value) =>
          Result.failure(exceptionOnFalse, StackTrace.current),
        _ => this,
      };

  /// Executes the provided callbacks based on the result type.
  ///
  /// Ideal for side effects.
  ///
  /// If the result is `Ok`, the `onOk` callback is called with the value.
  /// If the result is `Failure`, the `onFailure` callback is called with the
  /// exception and stack trace.
  ///
  /// Both callbacks are optional.
  ///
  /// - Parameters:
  ///   - onOk: A callback to be executed if the result is `Ok`.
  ///   - onFailure: A callback to be executed if the result is `Failure`.
  void tap({
    void Function(T value)? onOk,
    void Function(Exception failure, StackTrace stackTrace)? onFailure,
  }) =>
      switch (this) {
        Ok(:final value) => onOk?.call(value),
        Failure(:final failure, :final stackTrace) =>
          onFailure?.call(failure, stackTrace)
      };

  /// Converts the current result to a nullable value.
  ///
  /// If the result is `Ok`, it returns the contained value.
  /// If the result is `Failure`, it returns `null`.
  ///
  /// Returns:
  /// - `T?`: The contained value if the result is `Ok`, otherwise `null`.
  T? toNullable() => switch (this) {
        Ok(:final value) => value,
        Failure(failure: _, stackTrace: _) => null,
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
