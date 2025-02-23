import 'result.dart';

/// A future that will eventually resolve to a [Result]<[T]>.
/// This allows you to define a type that represents an
/// asynchronous operation that will return a [Result]<[T]> when completed.
typedef FutureResult<T extends Object, E extends Object> = Future<Result<T, E>>;
