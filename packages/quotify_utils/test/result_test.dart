import 'dart:async';

import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:test/test.dart';

final class ArithmeticException implements Exception {
  ArithmeticException(this.message);

  final String message;
}

double divide(double a, double b) {
  if (b == 0) {
    throw ArithmeticException('Denominator cannot be zero');
  }

  return a / b;
}

void main() {
  group('equality', () {
    group('same type', () {
      test('Ok == Ok, with same value are equal', () {
        // ignore: prefer_const_constructors
        final intOk = Result.ok(10);
        // ignore: prefer_const_constructors
        final stringOk = Result.ok(10);

        expect(intOk == stringOk, isTrue);
      });

      test('Ok == Ok, with different value are different', () {
        // ignore: prefer_const_constructors
        final intOk = Result.ok(9);
        // ignore: prefer_const_constructors
        final stringOk = Result.ok(10);

        expect(intOk == stringOk, isFalse);
      });

      test('Failure == Failure, with different failure are different', () {
        // ignore: prefer_const_constructors
        final oopsFailure = Result.failure('oops', StackTrace.empty);
        // ignore: prefer_const_constructors
        final ooopsFailure = Result.failure('ooops', StackTrace.empty);

        expect(oopsFailure == ooopsFailure, isFalse);
      });

      test('Failure == Failure, with different stackTrace are different', () {
        // ignore: prefer_const_constructors
        final emptyStackTrace = Result.failure('oops', StackTrace.empty);
        // ignore: prefer_const_constructors
        final currentStackTrace = Result.failure('oops', StackTrace.current);

        expect(emptyStackTrace == currentStackTrace, isFalse);
      });

      test('Failure == Failure, with same failure and stackTrace are equal',
          () {
        // ignore: prefer_const_constructors
        final emptyStackTrace = Result.failure('oops', StackTrace.empty);
        // ignore: prefer_const_constructors
        final emptyStackTraceToo = Result.failure('oops', StackTrace.empty);

        expect(emptyStackTrace == emptyStackTraceToo, isTrue);
      });
    });
  });
  group('Result.guardSync', () {
    test('should return Ok with the value when is fine', () {
      final result = Result.guardSync(() => divide(10, 5));
      expect(result, isA<Ok>());
      expect(result.asOk.value, equals(2));
    });

    test('should return Failure with the expected type when fails', () {
      final result = Result.guardSync(() => divide(10, 0));
      expect(result, isA<Failure>());
      expect(result.asFailure.failure, isA<ArithmeticException>());
    });

    test('should rethrow the exception if is not the expected type', () {
      expect(
        () => Result.guardSync<String, FormatException>(
          () => throw ArithmeticException('Unexpected!'),
        ),
        throwsA(isA<ArithmeticException>()),
      );
    });
  });

  group('Result.guardAsync', () {
    test('should return Ok with the value when is fine', () async {
      final result = await Result.guardAsync(() => Future.value(divide(10, 5)));
      expect(result, isA<Ok>());
      expect(result.asOk.value, equals(2));
    });

    test('should return Failure with the expected type when fails', () async {
      final result = await Result.guardAsync(() => Future.value(divide(10, 0)));
      expect(result, isA<Failure>());
      expect(result.asFailure.failure, isA<ArithmeticException>());
    });

    test('should rethrow the exception if is not the expected type', () async {
      expect(
        () => Result.guardAsync<String, FormatException>(
          () => Future.error(ArithmeticException('Unexpected!')),
        ),
        throwsA(isA<ArithmeticException>()),
      );
    });
  });

  group('Result.guardAsyncWithTimeout', () {
    test('should return Ok with the value when is fine', () async {
      final result = await Result.guardAsyncWithTimeout(
        () => Future.value(divide(10, 5)),
        timeout: const Duration(seconds: 5),
        failureOnTimeout: 'oops',
      );
      expect(result, isA<Ok>());
      expect(result.asOk.value, equals(2));
    });

    test('should return Failure with the expected type when fails', () async {
      final result = await Result.guardAsyncWithTimeout<double, Exception>(
        () => Future.value(divide(10, 0)),
        timeout: const Duration(seconds: 5),
        failureOnTimeout: TimeoutException('oops'),
      );
      expect(result, isA<Failure<double, Exception>>());
      expect(result.asFailure.failure, isA<ArithmeticException>());
    });

    test('should return the onTimeoutFailure when Timeout exceeds fails',
        () async {
      final result = await Result.guardAsyncWithTimeout<double, Exception>(
        () => Future.delayed(const Duration(seconds: 10), () => divide(10, 0)),
        timeout: const Duration(seconds: 1),
        failureOnTimeout: TimeoutException('oops'),
      );
      expect(result, isA<Failure>());
      expect(result.asFailure.failure, isA<TimeoutException>());
    });

    test('should rethrow the exception if is not the expected type', () async {
      expect(
        () => Result.guardAsyncWithTimeout<String, FormatException>(
          () => Future.error(ArithmeticException('Unexpected!')),
          timeout: const Duration(seconds: 5),
          failureOnTimeout: const FormatException(
            'unrelated, but is sufficient for this test',
          ),
        ),
        throwsA(isA<ArithmeticException>()),
      );
    });
  });

  group('Result.unwrap', () {
    test('ok instances returns their value', () {
      const ten = 10;

      // ignore: prefer_const_constructors
      final aNumber = Result.ok(ten);

      expect(aNumber.unwrap(), equals(ten));
    });

    test('failure instances throws their failures', () {
      final aFailure =
          Result<Unit, Exception>.failure(Exception('oops'), StackTrace.empty);

      expect(aFailure.unwrap, throwsException);
    });
  });

  group('Result.flatMapSync', () {
    test('ok instances returns the callback wrapped into a result', () {
      const deyan = 'Deyan';

      // ignore: prefer_const_constructors
      final myName = Result.ok(deyan);

      final nameLength = myName.mapSync(
        (value) => value.length,
      );

      expect(nameLength, isA<Ok<int, Object>>());
      expect(nameLength.asOk.value, equals(deyan.length));
    });

    test(
        'failure instances returns the original failure and stackTraces '
        'wrapped into a result', () {
      final exception = Exception('oops');
      const stackTrace = StackTrace.empty;
      final myFailure = Result<String, Exception>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.mapSync(
        (value) => value.length,
      );

      expect(wouldBeNameLength, isA<Failure<int, Object>>());
      expect(wouldBeNameLength.asFailure.failure, equals(exception));
      expect(wouldBeNameLength.asFailure.stackTrace, equals(stackTrace));
    });

    test(
        'even when callback throws failure instances returns the original '
        'failure and stackTraces wrapped into a result', () {
      final exception = Exception('oops');
      const stackTrace = StackTrace.empty;
      final myFailure = Result<String, Exception>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.mapSync(
        (value) => throw const FormatException('a different exception'),
      );

      expect(wouldBeNameLength, isA<Failure<int, Object>>());
      expect(wouldBeNameLength.asFailure.failure, equals(exception));
      expect(wouldBeNameLength.asFailure.stackTrace, equals(stackTrace));
    });
  });

  group('Result.flatMapAsync', () {
    test('ok instances returns the callback wrapped into a result', () async {
      const deyan = 'Deyan';

      // ignore: prefer_const_constructors
      final myName = Result.ok(deyan);

      final nameLength = myName.mapAsync(
        (value) async => value.length,
      );

      expect(nameLength, completion(isA<Ok<int, Object>>()));
      expect((await nameLength).asOk.value, equals(deyan.length));
    });

    test(
        'failure instances returns the original failure and stackTraces '
        'wrapped into a result', () async {
      final exception = Exception('oops');
      const stackTrace = StackTrace.empty;
      final myFailure = Result<String, Exception>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.mapAsync(
        (value) async => value.length,
      );

      expect(wouldBeNameLength, completion(isA<Failure<String, Exception>>()));
      expect((await wouldBeNameLength).asFailure.failure, equals(exception));
      expect(
        (await wouldBeNameLength).asFailure.stackTrace,
        equals(stackTrace),
      );
    });

    test(
        'even when callback throws failure instances returns the original '
        'failure and stackTraces wrapped into a result', () async {
      final exception = Exception('oops');
      const stackTrace = StackTrace.empty;
      final myFailure = Result<String, Exception>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.mapAsync(
        (value) =>
            Future<int>.error(const FormatException('a different exception')),
      );

      final result = await wouldBeNameLength;

      expect(result, isA<Failure<String, Exception>>());
      expect(result.asFailure.failure, equals(exception));
      expect(
        result.asFailure.stackTrace,
        equals(stackTrace),
      );
    });
  });

  group('Result.fold', () {
    test('when ok, executes onOk', () {});
  });
}
