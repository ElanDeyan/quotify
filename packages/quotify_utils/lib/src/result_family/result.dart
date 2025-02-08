/// Copied from https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart
/// with subtle differences:
/// - Renames [Error] to [Failure].
/// - Type parameter in [Result.asFailure] getter.
/// - [Result] factories translated to const factories.
/// - [StackTrace] class inside the [Failure].
/// - Also some comments.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../result.dart';

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
  const factory Result.failure(E failure, [StackTrace? stackTrace]) = Failure;

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
  ) =>
      Future.sync(computation).then(Result<T, E>.ok).catchError(
            (Object error) => Result<T, E>.failure(error as E),
            test: (error) => error is E,
          );

  /// Executes an asynchronous computation with a specified timeout and returns
  /// a `FutureResult` containing either the result of the computation or a
  /// failure.
  ///
  /// If the computation completes successfully within the timeout duration, the
  /// result is wrapped in a `Result.ok`. If the computation times out, a
  /// `TimeoutException` is thrown and a `Result.failure` is returned with the
  /// provided `failureOnTimeout` value. If the computation throws an exception
  /// of type `E`, a `Result.failure` is returned with the exception. Any other
  /// exceptions are rethrown.
  ///
  /// - Parameters:
  ///   - computation: A `Future` function representing the asynchronous
  ///     computation to be executed.
  ///   - timeout: The duration within which the computation must complete.
  ///   - failureOnTimeout: The value to be returned in a `Result.failure` if
  ///     the computation times out.
  ///
  /// - Returns: A `FutureResult` containing either the result of the
  ///   computation or a failure.
  static FutureResult<T, E>
      guardAsyncWithTimeout<T extends Object, E extends Object>(
    Future<T> Function() computation, {
    required Duration timeout,
    required E failureOnTimeout,
  }) async =>
          Future.sync(computation)
              .timeout(timeout)
              .then(Result<T, E>.ok)
              .catchError(
            (Object error) {
              if (error is TimeoutException) {
                return Result<T, E>.failure(failureOnTimeout);
              }

              return Result<T, E>.failure(error as E);
            },
            test: (error) => error is E || error is TimeoutException,
          );

  /// Converts a stream of values of type `T` into a stream of `Result<T, E>`
  /// objects.
  ///
  /// Each value emitted by the input stream is wrapped in a `Result.ok` object.
  /// If an error occurs in the input stream, it is caught and wrapped in a
  /// `Result.failure` object, provided the error is of type `E`.
  ///
  /// The resulting stream is a broadcast stream, meaning it can be listened to
  /// multiple times.
  ///
  /// - Parameters:
  ///   - stream: The input stream of values of type `T`.
  ///
  /// - Returns: A broadcast stream of `Result<T, E>` objects.
  static Stream<Result<T, E>> guardStream<T extends Object, E extends Object>(
    Stream<T> stream,
  ) =>
      stream
          .map(
            Result<T, E>.ok,
          )
          .handleError(
            (Object error, StackTrace stackTrace) => Result<T, E>.failure(
              error as E,
              stackTrace == StackTrace.empty ? null : stackTrace,
            ),
            test: (error) => error is E,
          )
          .asBroadcastStream();

  static FutureResult<T, E> retryAsync<T extends Object, E extends Object>(
    Future<T> Function() computation, {
    int maxAttempts = 1,
    Duration delay = const Duration(milliseconds: 500),
    Duration Function(int attempt)? delayStrategy,
    bool Function(E failure)? retryIf,
  }) async {
    assert(maxAttempts > 0, 'maxAttempts should be higher than 0');
    assert(!delay.isNegative, 'delay should be positive');

    delayStrategy ??= (attempt) => delay * (math.pow(2, attempt));

    late Result<T, E> lastResult;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      lastResult = await Result.guardAsync<T, E>(computation);

      switch (lastResult) {
        case Ok():
          return lastResult;
        case Failure(:final failure):
          if (retryIf?.call(failure) ?? true) {
            if (attempt < maxAttempts) {
              await Future<void>.delayed(delayStrategy(attempt));
              continue;
            }
          }
          return lastResult;
      }
    }

    return lastResult;
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
    F Function(E exception)? failureMapper,
  }) =>
      switch (this) {
        Ok<T, E>(:final value) => Result.guardSync(() => callback(value)),
        Failure<T, E>(:final failure) => Result.failure(
            failureMapper?.call(failure) ?? failure as F,
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
  FutureResult<R, F> mapAsync<R extends Object, F extends Object>(
    Future<R> Function(T value) callback, {
    F Function(E exception)? failureMapper,
  }) async =>
      switch (this) {
        Ok(:final value) => await Result.guardAsync(() => callback(value)),
        Failure(:final failure) => Result.failure(
            failureMapper?.call(failure) ?? failure as F,
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
    required R Function(E exception) onFailure,
  }) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Failure(:final failure) => onFailure(failure),
      };

  /// Returns the value if the result is `Ok`, otherwise returns the provided
  /// fallback value if the result is `Failure`.
  ///
  /// - Parameter fallback: The value to return if the result is `Failure`.
  /// - Returns: The value if the result is `Ok`, otherwise the fallback value.
  T unwrapOrElse(T Function() callback) => switch (this) {
        Ok(:final value) => value,
        Failure() => callback(),
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
    T Function(E exception) onFailure,
  ) =>
      switch (this) {
        Ok() => this,
        Failure(:final failure) => Result.guardSync(() => onFailure(failure)),
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
    Future<T> Function(E exception) onFailure,
  ) async =>
      switch (this) {
        Ok() => this,
        Failure(:final failure) =>
          await Result.guardAsync(() => onFailure(failure)),
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
          Result.failure(exceptionOnFalse),
        _ => this,
      };

  /// Applies a list of predicates with corresponding error functions to the
  /// current `Result` object. If the current object is an `Ok` variant, it
  /// sequentially applies each predicate to the value. If a predicate returns
  /// `false`, the corresponding error function is used to transform the value
  /// into an error, and the `Result` becomes a `Failure`. If the current object
  /// is already a `Failure`, it remains unchanged.
  ///
  /// - Parameters:
  ///   - predicatesWithErrors: A list of tuples where each tuple contains a
  ///     predicate function and an error function. The predicate function takes
  ///     a value of type `T` and returns a `bool`. The error function takes a
  ///     value of type `T` and returns an error of type `E`.
  ///
  /// - Returns: A `Result` object that is either an `Ok` or a `Failure`
  ///   depending on the evaluation of the predicates.
  Result<T, E> whereAll(
    List<(bool Function(T value), E Function(T value))> predicatesWithErrors,
  ) =>
      switch (this) {
        Ok(:final value) => predicatesWithErrors.fold(
            this,
            (acc, predicatePair) =>
                acc.where(predicatePair.$1, predicatePair.$2(value)),
          ),
        Failure() => this,
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
    void Function(E failure)? onFailure,
  }) =>
      switch (this) {
        Ok(:final value) => onOk?.call(value),
        Failure(:final failure) => onFailure?.call(failure)
      };

  Future<void> tapAsync({
    Future<void> Function(T value)? onOk,
    Future<void> Function(E failure)? onFailure,
  }) async =>
      switch (this) {
        Ok(:final value) => onOk?.call(value),
        Failure(:final failure) => onFailure?.call(failure)
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
        Failure() => null,
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
  const Failure(this.failure, [this._stackTrace]);

  /// Returned error in result
  final E failure;

  /// Stack trace related to this [Failure]. If null, when calling the
  /// [stackTrace] getter it will return [StackTrace.current].
  final StackTrace? _stackTrace;

  /// Stack trace related to this [Failure].
  ///
  StackTrace get stackTrace => _stackTrace ?? StackTrace.current;

  @override
  bool operator ==(covariant Failure<T, E> other) =>
      failure == other.failure && _stackTrace == other._stackTrace;

  @override
  int get hashCode => Object.hashAll([failure, _stackTrace]);

  @override
  String toString() => 'Result<$T>.error(\n\t$failure,\n\t$_stackTrace,\n)';
}
