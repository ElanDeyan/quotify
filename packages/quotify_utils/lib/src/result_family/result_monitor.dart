import '../../result.dart';

abstract final class ResultMonitor {
  static final _timings = <String, List<Duration>>{};
  static final _errors = <String, int>{};

  static FutureResult<T, E> track<T extends Object, E extends Object>(
    String operation,
    Future<T> Function() computation,
  ) async {
    final stopwatch = Stopwatch()..start();
    final result = await Result.guardAsync<T, E>(computation);
    stopwatch.stop();

    _timings.putIfAbsent(operation, () => []).add(stopwatch.elapsed);

    if (result case Failure<T, E>()) {
      _errors.update(operation, (value) => value + 1, ifAbsent: () => 1);
    }

    return result;
  }

  static Map<String, ({Duration average, int countErrors})> get stats => {
    for (final MapEntry(key: operation, value: timing) in _timings.entries)
      operation: (
        average:
            timing.fold(
              Duration.zero,
              (previousValue, element) => previousValue + element,
            ) ~/
            timing.length,
        countErrors: _errors[operation] ?? 0,
      ),
  };
}
