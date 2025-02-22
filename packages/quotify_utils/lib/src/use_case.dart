abstract interface class UseCase<A extends Record?, R extends Object?> {
  R call([A arguments]);
}
