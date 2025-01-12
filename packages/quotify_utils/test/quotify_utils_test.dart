import 'package:quotify_utils/quotify_utils.dart';
import 'package:test/test.dart';

import 'functions_sample.dart';

void main() {
  group('with package:test', () {
    group('sync', () {
      test('Result from computation: Ok', () {
        expect(
          Result.guardSync(iWillReturnAnIntSynchronously),
          isA<Ok<int>>(),
        );
        expect(
          Result.guardSync(iWillReturnAnIntSynchronously).asOk.value,
          equals(1),
        );
      });
      test('Result from computation: Failure', () {
        expect(
          Result.guardSync(iWillThrowSynchronously),
          isA<Failure<int>>(),
        );
        expect(
          Result.guardSync(iWillThrowSynchronously).asFailure.failure,
          isException,
        );
      });
    });

    group('async', () {
      test('Result from computation: Ok', () async {
        expect(
          Result.guardAsync(iWillReturnAnIntAsynchronously),
          completion(isA<Ok<int>>()),
        );
        expect(
          (await Result.guardAsync(iWillReturnAnIntAsynchronously)).asOk.value,
          equals(1),
        );
      });
      test('Result from computation: Failure', () async {
        expect(
          Result.guardAsync(iWillThrowAsynchronously),
          completion(isA<Failure<int>>()),
        );
        expect(
          (await Result.guardAsync(iWillThrowAsynchronously)).asFailure.failure,
          isException,
        );
      });
    });
  });
}
