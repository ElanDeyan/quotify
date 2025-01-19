import '../../result.dart';

final class CachedResult<T extends Object, E extends Object> {
  CachedResult({
    required Future<T> Function() computation,
    required Duration ttl,
  })  : _computation = computation,
        _ttl = ttl;

  final Future<T> Function() _computation;
  final Duration _ttl;

  FutureResult<T, E>? _cachedResult;
  DateTime? _lastComputed;

  bool get isExpired =>
      _lastComputed == null || DateTime.now().difference(_lastComputed!) > _ttl;

  FutureResult<T, E> get value async {
    if (_cachedResult == null || isExpired) {
      _cachedResult = Result.guardAsync(_computation);
      _lastComputed = DateTime.now();
    }

    return _cachedResult!;
  }

  void invalidate() {
    _cachedResult = null;
    _lastComputed = null;
  }
}
