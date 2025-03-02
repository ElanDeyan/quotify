abstract interface class UseCase<R extends Object?> {
  const UseCase();

  R call();
}
