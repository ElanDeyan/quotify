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
sealed class Result<T> {
  const Result();

  /// Creates an instance of Result containing a value
  const factory Result.ok(T value) = Ok;

  /// Create an instance of Result containing an error
  const factory Result.failure(Object failure, StackTrace stackTrace) = Failure;

  /// Returns a [Result] from a synchronous function call.
  factory Result.fromComputationSync(T Function() computation) {
    try {
      return Result.ok(computation());
    } on Object catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }

  /// Returns a [Result] from a synchronous function call.
  static FutureResult<T> fromComputationAsync<T>(
    Future<T> Function() computation,
  ) async {
    try {
      final result = await computation();
      return Result.ok(result);
    } on Object catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }

  /// Convenience method to cast to [Ok]
  @visibleForTesting
  Ok<T> get asOk => this as Ok<T>;

  /// Convenience method to cast to [Failure]
  @visibleForTesting
  Failure<T> get asFailure => this as Failure<T>;
}

/// Subclass of Result for values
final class Ok<T> extends Result<T> {
  /// Subclass of Result for values
  const Ok(this.value);

  /// Returned value in result
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
final class Failure<T> extends Result<T> {
  /// Subclass of Result for errors
  const Failure(this.failure, this.stackTrace);

  /// Returned error in result
  final Object failure;

  /// Stack trace related to this [Failure].
  final StackTrace stackTrace;

  @override
  String toString() => 'Result<$T>.error(\n\t$failure,\n\t$stackTrace,\n)';
}
