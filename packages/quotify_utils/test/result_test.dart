import 'package:quotify_utils/quotify_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Result.unwrap', () {
    test('ok instances returns their value', () {
      const ten = 10;
      const aNumber = Result.ok(ten);

      expect(aNumber.unwrap(), equals(ten));
    });

    test('failure instances throws their failures', () {
      final aFailure =
          Result<void>.failure(Exception('oops'), StackTrace.empty);

      expect(aFailure.unwrap, throwsException);
    });
  });

  group('Result.flatMapSync', () {
    test('ok instances returns the callback wrapped into a result', () {
      const deyan = 'Deyan';
      const myName = Result.ok(deyan);

      final nameLength = myName.flatMapSync(
        (value) => value.length,
      );

      expect(nameLength, isA<Ok<int>>());
      expect(nameLength.asOk.value, equals(deyan.length));
    });

    test(
        'failure instances returns the original failure and stackTraces '
        'wrapped into a result', () {
      final exception = Exception('oops');
      const stackTrace = StackTrace.empty;
      final myFailure = Result<String>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.flatMapSync(
        (value) => value.length,
      );

      expect(wouldBeNameLength, isA<Failure<int>>());
      expect(wouldBeNameLength.asFailure.failure, equals(exception));
      expect(wouldBeNameLength.asFailure.stackTrace, equals(stackTrace));
    });

    test(
        'even when callback throws failure instances returns the original '
        'failure and stackTraces wrapped into a result', () {
      final exception = Exception('oops');
      const stackTrace = StackTrace.empty;
      final myFailure = Result<String>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.flatMapSync(
        (value) => throw const FormatException('a different exception'),
      );

      expect(wouldBeNameLength, isA<Failure<int>>());
      expect(wouldBeNameLength.asFailure.failure, equals(exception));
      expect(wouldBeNameLength.asFailure.stackTrace, equals(stackTrace));
    });
  });

  group('Result.flatMapAsync', () {
    test('ok instances returns the callback wrapped into a result', () async {
      const deyan = 'Deyan';
      const myName = Result.ok(deyan);

      final nameLength = myName.flatMapAsync(
        (value) async => value.length,
      );

      expect(nameLength, completion(isA<Ok<int>>()));
      expect((await nameLength).asOk.value, equals(deyan.length));
    });

    test(
        'failure instances returns the original failure and stackTraces '
        'wrapped into a result', () async {
      final exception = Exception('oops');
      const stackTrace = StackTrace.empty;
      final myFailure = Result<String>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.flatMapAsync(
        (value) async => value.length,
      );

      expect(wouldBeNameLength, completion(isA<Failure<int>>()));
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
      final myFailure = Result<String>.failure(
        exception,
        stackTrace,
      );

      final wouldBeNameLength = myFailure.flatMapAsync(
        (value) =>
            Future<int>.error(const FormatException('a different exception')),
      );

      final result = await wouldBeNameLength;

      expect(result, isA<Failure<int>>());
      expect(result.asFailure.failure, equals(exception));
      expect(
        result.asFailure.stackTrace,
        equals(stackTrace),
      );
    });
  });
}
