import '../../result.dart';

/// A class that memoizes the result of a computation.
///
/// The [MemoizedResult] class is used to cache the result of a computation
/// so that it is only computed once and reused on subsequent accesses.
///
/// The computation is provided as a function that returns a value of type [T].
/// The result is wrapped in a [Result] object that can also contain an error
/// of type [E].
///
/// The [MemoizedResult] class provides methods to access the memoized result
/// and to invalidate the cached result, forcing a recomputation on the next
/// access.
final class MemoizedResult<T extends Object, E extends Object> {
  /// Creates a [MemoizedResult] with the given computation function.
  ///
  /// The computation function is provided as a parameter and is used to
  /// compute the result when needed.
  MemoizedResult(this._computation);

  /// The computation function that produces the result.
  ///
  /// This function is called to compute the result when it is first accessed
  /// or when the cached result is invalidated.
  final T Function() _computation;

  /// The cached result of the computation.
  ///
  /// This field stores the result of the computation wrapped in a [Result]
  /// object. It is initially `null` and is computed on the first access.
  Result<T, E>? memoizedResult;

  /// Gets the memoized result of the computation.
  ///
  /// If the result has already been computed and cached, it is returned.
  /// Otherwise, the computation function is called to compute the result,
  /// which is then cached and returned.
  Result<T, E> get value => memoizedResult ??= Result.guardSync(_computation);

  /// Invalidates the cached result.
  ///
  /// This method sets the cached result to `null`, forcing a recomputation
  /// on the next access to the [value] getter.
  void invalidate() => memoizedResult = null;
}

/// A class that memoizes the result of an asynchronous computation.
///
/// The [MemoizedResultAsync] class allows you to cache the result of an
/// asynchronous computation and retrieve it without re-executing the
/// computation. The cached result can be invalidated to force a re-computation.
///
/// [T] is the type of the successful result.
/// [E] is the type of the error result.
final class MemoizedResultAsync<T extends Object, E extends Object> {
  /// Creates a [MemoizedResultAsync] with the given asynchronous computation.
  ///
  /// The [_computation] parameter is a function that returns a [Future] of
  /// type [T].
  MemoizedResultAsync(this._computation);

  /// The asynchronous computation to be memoized.
  final Future<T> Function() _computation;

  /// The memoized result of the asynchronous computation.
  ///
  /// This is initially `null` and will be set to the result of the computation
  /// when [value] is accessed for the first time.
  FutureResult<T, E>? memoizedResult;

  /// Returns the memoized result of the asynchronous computation.
  ///
  /// If the result has not been computed yet, it will execute the computation
  /// and cache the result. Subsequent accesses will return the cached result.
  FutureResult<T, E> get value =>
      memoizedResult ??= Result.guardAsync(_computation);

  /// Invalidates the cached result, forcing a re-computation the next time
  /// [value] is accessed.
  void invalidate() => memoizedResult = null;
}
