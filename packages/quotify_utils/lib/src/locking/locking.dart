import 'package:synchronized/synchronized.dart';

sealed class Locking {
  const Locking();

  Future<T> synchronized<T extends Object?>(Future<T> Function() action);
}

final class RealLocking implements Locking {
  RealLocking({this.reentrant = false});
  final bool reentrant;

  late final _lock = Lock(reentrant: reentrant);

  @override
  Future<T> synchronized<T extends Object?>(Future<T> Function() action) =>
      _lock.synchronized(action);
}

final class FakeLocking implements Locking {
  const FakeLocking();

  @override
  Future<T> synchronized<T extends Object?>(Future<T> Function() action) =>
      action();
}
