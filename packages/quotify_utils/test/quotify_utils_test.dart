import 'package:quotify_utils/quotify_utils.dart';
import 'package:test/test.dart';

import 'functions_sample.dart';



void main() {
  group('with package:test', () {
    group('sync', () {
      test('Result from computation: Ok', () {
        expect(
          Result.fromComputationSync(iWillReturnAnIntSynchronously),
          isA<Ok<int>>(),
        );
        expect(
          Result.fromComputationSync(iWillReturnAnIntSynchronously).asOk.value,
          equals(1),
        );
      });
      test('Result from computation: Failure', () {
        expect(
          Result.fromComputationSync(iWillThrowSynchronously),
          isA<Failure<int>>(),
        );
        expect(
          Result.fromComputationSync(iWillThrowSynchronously).asFailure.failure,
          isException,
        );
      });
    });

    group('async', () {
      test('Result from computation: Ok', () async {
        expect(
          Result.fromComputationAsync(iWillReturnAnIntAsynchronously),
          completion(isA<Ok<int>>()),
        );
        expect(
          (await Result.fromComputationAsync(iWillReturnAnIntAsynchronously))
              .asOk
              .value,
          equals(1),
        );
      });
      test('Result from computation: Failure', () async {
        expect(
          Result.fromComputationAsync(iWillThrowAsynchronously),
          completion(isA<Failure<int>>()),
        );
        expect(
          (await Result.fromComputationAsync(iWillThrowAsynchronously))
              .asFailure
              .failure,
          isException,
        );
      });
    });
  });

  group('with package:checks', () {
    group('sync', () {
      test('Result from computation: Ok', () {
        expect(
          Result.fromComputationSync(iWillReturnAnIntSynchronously),
          isA<Ok<int>>(),
        );
        expect(
          Result.fromComputationSync(iWillReturnAnIntSynchronously).asOk.value,
          equals(1),
        );
      });
      test('Result from computation: Failure', () {
        expect(
          Result.fromComputationSync(iWillThrowSynchronously),
          isA<Failure<int>>(),
        );
        expect(
          Result.fromComputationSync(iWillThrowSynchronously).asFailure.failure,
          isException,
        );
      });
    });
  });
}
