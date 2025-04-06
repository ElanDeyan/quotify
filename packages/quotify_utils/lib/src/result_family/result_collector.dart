import '../../result.dart';

/// A class that collects results of type `Result<T, E>`.
///
/// This class maintains two lists: one for successful values of type `T`
/// and another for failures of type `E`.
///
/// Type Parameters:
/// - `T`: The type of successful values.
/// - `E`: The type of failure values.
///
/// Example usage:
/// ```dart
/// final collector = ResultCollector<int, String>();
/// collector.add(Result.ok(1));
/// collector.add(Result.failure('error', StackTrace.current));
/// final result = collector.collect();
/// ```
///
/// Methods:
/// - `add(Result<T, E> result)`: Adds a result to the collector. If the result
///   is successful, it adds the value to the `_values` list. If the result is
///   a failure, it adds the failure to the `_failures` list.
/// - `collect()`: Returns a `Result` containing a list of all successful values
///   if there are no failures. If there are failures, it returns a `Result`
///   containing a list of all failures and the current stack trace.
final class ResultCollector<T extends Object, E extends Object> {
  /// A class responsible for collecting and managing results.
  ///
  /// The `ResultCollector` class provides functionality to gather results
  /// from various operations and manage them in a structured manner.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// ResultCollector collector = ResultCollector();
  /// collector.addResult(someResult);
  /// var allResults = collector.getAllResults();
  /// ```
  ///
  /// This class can be particularly useful in scenarios where multiple
  /// results need to be aggregated and processed collectively.
  ResultCollector() : _values = [], _failures = [];
  final List<T> _values;
  final List<E> _failures;

  /// Adds a [Result] to the collector. If the result is an [Ok] value, it is
  /// added to the `_values` list. If the result is a [Failure], the failure is
  /// added to the `_failures` list.
  ///
  /// - Parameter result: The [Result] to be added, which can be either
  ///   an [Ok] or a [Failure].
  ///
  /// Example:
  /// ```dart
  /// final collector = ResultCollector<int, String>();
  /// collector.add(Ok(42));
  /// collector.add(Failure('Error'));
  /// ```
  void add(Result<T, E> result) => switch (result) {
    Ok(:final value) => _values.add(value),
    Failure(:final failure, stackTrace: _) => _failures.add(failure),
  };

  /// Collects the results and returns a [Result] object.
  ///
  /// If there are no failures, it returns a [Result.ok] containing the list
  /// of values.
  ///
  /// If there are failures, it returns a [Result.failure] containing the list
  /// of errors and the current stack trace.
  ///
  /// Returns:
  /// - `Result<List<T>, List<E>>`: A [Result] object containing either the
  ///   list of values or the list of errors and the stack trace.
  Result<List<T>, List<E>> collect() =>
      _failures.isEmpty
          ? Result.ok(_values)
          : Result.failure(_failures, StackTrace.current);
}
