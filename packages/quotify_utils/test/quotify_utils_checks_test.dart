import 'package:checks/checks.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:test/test.dart';

import 'functions_sample.dart';

void main() {
  group('with package:checks', () {
    group('sync', () {
      test('Result from computation: Ok', () {
        check(Result.fromComputationSync(iWillReturnAnIntSynchronously))
            .isA<Ok<int>>();

        check(
          Result.fromComputationSync(iWillReturnAnIntSynchronously).asOk.value,
        ).equals(1);
      });
      test('Result from computation: Failure', () {
        check(Result.fromComputationSync(iWillThrowSynchronously))
            .isA<Failure<int>>();

        check(
          Result.fromComputationSync(iWillThrowSynchronously).asFailure.failure,
        ).isA<Exception>();
      });
    });

    group('async', () {
      test('Result from computation: Ok', () async {
        await check(
          Result.fromComputationAsync(iWillReturnAnIntAsynchronously),
        ).completes(
          (result) => result.isA<Ok<int>>(),
        );

        check(
          (await Result.fromComputationAsync(iWillReturnAnIntAsynchronously))
              .asOk
              .value,
        ).equals(1);
      });
      test('Result from computation: Failure', () async {
        await check(
          Result.fromComputationAsync(iWillThrowAsynchronously),
        ).completes(
          (result) => result.isA<Failure<int>>(),
        );

        check(
          (await Result.fromComputationAsync(iWillThrowAsynchronously))
              .asFailure
              .failure,
        ).isA<Exception>();
      });
    });
  });
}
