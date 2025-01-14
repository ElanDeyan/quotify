import '../quotify_utils.dart';

extension ListOfResultsExtension<T extends Object, E extends Exception>
    on List<Result<T, E>> {
  bool everyOk() => every(
        (element) => element.isOk,
      );

  bool everyFailure() => every(
        (element) => element.isFailure,
      );

  bool anyOk() => any(
        (element) => element.isOk,
      );

  bool anyFailure() => any(
        (element) => element.isFailure,
      );

  Iterable<Ok<T, E>> get allOks => whereType();

  Iterable<Failure<T, E>> get allFailures => whereType();
}

extension IterableExtension<T extends Object> on Iterable<T> {
  Iterable<Result<T, E>> resultMap<E extends Exception>(
    Result<T, E> Function(T element) toResult,
  ) =>
      map(toResult);
}
