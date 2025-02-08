import '../../result.dart';

extension ContextExtension<C extends Object, T extends Object, E extends Object>
    on Result<T, E> {
  Result<R, F> mapWithContextSync<R extends Object, F extends Object>(
    C context,
    R Function(T value, C context) mapper, {
    F Function(E)? failureMapper,
  }) =>
      mapSync(
        (value) => mapper(value, context),
        failureMapper: failureMapper,
      );

  FutureResult<R, F> mapWithContextAsync<R extends Object, F extends Object>(
    C context,
    Future<R> Function(T value, C context) mapper, {
    F Function(E)? failureMapper,
  }) =>
      mapAsync(
        (value) => mapper(value, context),
        failureMapper: failureMapper,
      );
}
