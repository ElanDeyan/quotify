import '../../result.dart';

/// Result related extension for iterable
extension IterableExtension<T extends Object> on Iterable<T> {
  /// Maps each element of the iterable to a `Result` object using the
  /// provided function.
  ///
  /// The `toResult` function is applied to each element of the iterable, and
  /// the resulting `Result` objects are returned as a new iterable.
  ///
  /// - Parameter toResult: A function that takes an element of type `T` and
  ///   returns a `Result<T, E>`.
  /// - Returns: An iterable of `Result<T, E>` objects.
  Iterable<Result<T, E>> mapResults<E extends Exception>(
    Result<T, E> Function(T element) toResult,
  ) => map(toResult);
}
