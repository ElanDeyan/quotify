import '../../result.dart';

extension ResultStreamExtension<T extends Object, E extends Object>
    on Result<T, E> {
  Stream<T> asStream() => switch (this) {
        Ok(:final value) => Stream.value(value).asBroadcastStream(),
        Failure(:final failure, :final stackTrace) =>
          Stream<T>.error(failure, stackTrace).asBroadcastStream(),
      };
}

extension StreamResultExtension<T extends Object> on Stream<T> {
  Stream<Result<T, E>> asResults<E extends Object>() => map(Result<T, E>.ok)
      .handleError(
        (Object error, StackTrace stackTrace) =>
            Result.failure(error as E, stackTrace),
        test: (error) => error is E,
      )
      .asBroadcastStream();

  Future<Result<List<T>, E>> collectResults<E extends Object>() async {
    try {
      final results = await toList();

      return Result.ok(results);
    } on E catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    } on Object {
      rethrow;
    }
  }
}
