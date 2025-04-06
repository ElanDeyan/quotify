import '../../result.dart';

extension FutureExtension<T extends Object, E extends Object> on Result<T, E> {
  Future<T> asFuture() async => switch (this) {
    Ok(:final value) => value,
    Failure(:final failure, :final stackTrace) => Error.throwWithStackTrace(
      failure,
      stackTrace,
    ),
  };
}
