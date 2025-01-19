import '../../result.dart';

/// Extensions for a list of Results.
extension ListOfResultsExtension<T extends Object, E extends Object>
    on List<Result<T, E>> {
  /// Checks if all elements in the list are successful results.
  ///
  /// Returns `true` if all elements are `Ok`, otherwise `false`.
  bool everyOk() => every(
        (element) => element.isOk,
      );

  /// Checks if all elements in the list are failure results.
  ///
  /// Returns `true` if all elements are `Failure`, otherwise `false`.
  bool everyFailure() => every(
        (element) => element.isFailure,
      );

  /// Checks if any element in the list is a successful result.
  ///
  /// Returns `true` if at least one element is `Ok`, otherwise `false`.
  bool anyOk() => any(
        (element) => element.isOk,
      );

  /// Checks if any element in the list is a failure result.
  ///
  /// Returns `true` if at least one element is `Failure`, otherwise `false`.
  bool anyFailure() => any(
        (element) => element.isFailure,
      );

  /// Gets an iterable of all successful results in the list.
  ///
  /// Returns an iterable containing all elements of type `Ok<T, E>`.
  Iterable<Ok<T, E>> get allOks => whereType();

  /// Gets an iterable of all failure results in the list.
  ///
  /// Returns an iterable containing all elements of type `Failure<T, E>`.
  Iterable<Failure<T, E>> get allFailures => whereType();
}
