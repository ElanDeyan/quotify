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
import 'result_extension.dart';

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
@immutable
sealed class Result<T extends Object, E extends Object> {
  const Result();

  /// Creates an instance of Result containing a value
  const factory Result.ok(T value) = Ok;

  /// Create an instance of Result containing an error
  const factory Result.failure(E failure, StackTrace stackTrace) = Failure;

  /// A factory constructor that executes a synchronous computation and returns
  /// a `Result` object. If the computation completes successfully, it returns
  /// a `Result.ok` with the computed value. If an exception of type `E` is
  /// thrown, it returns a `Result.failure` with the error and stack trace.
  /// Any other exceptions are rethrown.
  ///
  /// - Parameter computation: A function that performs the computation and
  ///   returns a value of type `T`.
  ///
  /// - Returns: A `Result` object containing either the computed value or the
  ///   error and stack trace.
  static Result<T, E> guardSync<T extends Object, E extends Object>(
    T Function() computation,
  ) {
    try {
      return Result.ok(computation());
    } on E catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    } on Object {
      rethrow;
    }
  }

  /// Executes an asynchronous computation and returns a `FutureResult`
  /// containing either the result of the computation or an exception if one
  /// occurs.
  ///
  /// This method catches exceptions of type `E` and returns them as a
  /// `Result.failure`.
  ///
  /// Any other exceptions are rethrown.
  ///
  /// - Parameters:
  ///   - computation: A function that returns a `Future` of type `T`.
  ///
  /// - Returns: A `FutureResult` containing either the result of the
  /// computation or an exception of type `E`.
  ///
  /// - Throws: Any exceptions that are not of type `E`.
  static FutureResult<T, E> guardAsync<T extends Object, E extends Object>(
    Future<T> Function() computation,
  ) async {
    try {
      final result = await computation();
      return Result.ok(result);
    } on E catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    } on Object {
      rethrow;
    }
  }

  /// Combines a list of `Result` objects into a single `Result` containing an
  /// iterable of the values from the successful results.
  ///
  /// If any of the results in the list is a failure, the first failure is
  /// returned.
  ///
  /// - Parameters:
  ///   - results: A list of `Result` objects to be combined.
  ///
  /// - Returns: A `Result` containing an iterable of the values from the
  ///   successful results, or the first failure if any result is a failure.
  static Result<Iterable<T>, E> combine<T extends Object, E extends Object>(
    List<Result<T, E>> results,
  ) {
    if (results.anyFailure()) {
      return Result.failure(
        results.allFailures.first.failure,
        results.allFailures.first.stackTrace,
      );
    }

    return Result.ok(results.allOks.map((e) => e.value));
  }

  @override
  bool operator ==(covariant Result<T, E> other) => switch ((this, other)) {
        (final Ok<T, E> first, final Ok<T, E> second) => first == second,
        (final Ok<T, E> _, final Failure<T, E> _) => false,
        (final Failure<T, E> _, final Ok<T, E> _) => false,
        (final Failure<T, E> first, final Failure<T, E> second) =>
          first == second,
      };

  @override
  int get hashCode => switch (this) {
        final Ok<T, E> ok => ok.hashCode,
        final Failure<T, E> failure => failure.hashCode,
      };

  /// Unwraps the result, returning the value if it is an `Ok` instance,
  /// or throwing the failure if it is a `Failure` instance.
  ///
  /// Throws:
  /// - The failure contained in the `Failure` instance.
  T unwrap() => switch (this) {
        Ok<T, E>(:final value) => value,
        Failure<T, E>(:final failure, :final stackTrace) =>
          Error.throwWithStackTrace(failure, stackTrace),
      };

  /// Maps the current `Result` to a new `Result` by applying the provided
  /// synchronous callback function to the value if the result is `Ok`.
  ///
  /// If the result is `Failure`, it applies the optional `failureMapper`
  /// function to the exception and stack trace to create a new failure.
  ///
  /// If `failureMapper` is not provided, the original exception is cast to
  /// the new failure type `F`.
  ///
  /// - Parameters:
  ///   - callback: A function that takes the value of type `T` and returns
  ///     a new value of type `R`.
  ///   - failureMapper: An optional function that takes the exception of type
  ///     `E` and the stack trace, and returns a new exception of type `F`.
  ///
  /// - Returns: A new `Result` of type `Result<R, F>`.
  Result<R, F> mapSync<R extends Object, F extends Object>(
    R Function(T value) callback, {
    F Function(E exception, StackTrace stackTrace)? failureMapper,
  }) =>
      switch (this) {
        Ok<T, E>(:final value) => Result.guardSync(() => callback(value)),
        Failure<T, E>(:final failure, :final stackTrace) => Result.failure(
            failureMapper?.call(failure, stackTrace) ?? failure as F,
            stackTrace,
          ),
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
  FutureResult<R, F> mapAsync<R extends Object, F extends Exception>(
    Future<R> Function(T value) callback, {
    F Function(E exception, StackTrace stackTrace)? failureMapper,
  }) async =>
      switch (this) {
        Ok(:final value) => await Result.guardAsync(() => callback(value)),
        Failure(:final failure, :final stackTrace) => Result.failure(
            failureMapper?.call(failure, stackTrace) ?? failure as F,
            stackTrace,
          ),
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
  R fold<R extends Object>({
    required R Function(T value) onOk,
    required R Function(E exception, StackTrace stackTrace) onFailure,
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
  T getOrElse(T Function() callback) => switch (this) {
        Ok(:final value) => value,
        Failure(failure: _, stackTrace: _) => callback(),
      };

  /// Recovers from a failure by synchronously executing the provided callback.
  ///
  /// If the current result is an `Ok`, it returns the current result.
  /// If the current result is a `Failure`, it invokes the [onFailure] callback
  /// with the failure and stack trace, and returns a new `Result` based on the
  /// callback's return value.
  ///
  /// The [onFailure] callback takes two parameters:
  /// - exception: The exception that caused the failure.
  /// - stackTrace: The stack trace associated with the failure.
  ///
  /// Returns a new `Result` based on the outcome of the [onFailure] callback.
  Result<T, E> recoverSync(
    T Function(E exception, StackTrace stackTrace) onFailure,
  ) =>
      switch (this) {
        Ok(value: _) => this,
        Failure(:final failure, :final stackTrace) =>
          Result.guardSync(() => onFailure(failure, stackTrace)),
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
  FutureResult<T, E> recoverAsync(
    Future<T> Function(E exception, StackTrace stackTrace) onFailure,
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
  Result<T, E> where(
    bool Function(T value) predicateOnOk,
    E exceptionOnFalse,
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
    void Function(E failure, StackTrace stackTrace)? onFailure,
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
  Ok<T, E> get asOk => this as Ok<T, E>;

  /// A getter that checks if the current instance is of type `Ok<T, E>`.
  ///
  /// Returns `true` if the instance is of type `Ok<T, E>`, otherwise `false`.
  bool get isOk => this is Ok<T, E>;

  /// Convenience method to cast to [Failure]
  @visibleForTesting
  Failure<T, E> get asFailure => this as Failure<T, E>;

  /// Returns `true` if the result is a failure.
  ///
  /// This getter checks if the current instance is of type `Failure<T, E>`.
  bool get isFailure => this is Failure<T, E>;
}

/// Subclass of Result for values
@immutable
final class Ok<T extends Object, E extends Object> extends Result<T, E> {
  /// Subclass of Result for values
  const Ok(this.value);

  /// Returned value in result
  final T value;

  @override
  bool operator ==(covariant Ok<T, E> other) => value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
@immutable
final class Failure<T extends Object, E extends Object> extends Result<T, E> {
  /// Subclass of Result for errors
  const Failure(this.failure, this.stackTrace);

  /// Returned error in result
  final E failure;

  /// Stack trace related to this [Failure].
  final StackTrace stackTrace;

  @override
  bool operator ==(covariant Failure<T, E> other) =>
      failure == other.failure && stackTrace == other.stackTrace;

  @override
  int get hashCode => Object.hashAll([failure, stackTrace]);

  @override
  String toString() => 'Result<$T>.error(\n\t$failure,\n\t$stackTrace,\n)';
}
