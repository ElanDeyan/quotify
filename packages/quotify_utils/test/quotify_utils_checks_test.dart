import 'package:checks/checks.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:test/test.dart';

import 'functions_sample.dart';

void main() {
  group('with package:checks', () {
    group('sync', () {
      test('Result from computation: Ok', () {
        check(Result.guardSync(iWillReturnAnIntSynchronously)).isA<Ok<int>>();

        check(
          Result.guardSync(iWillReturnAnIntSynchronously).asOk.value,
        ).equals(1);
      });
      test('Result from computation: Failure', () {
        check(Result.guardSync(iWillThrowSynchronously)).isA<Failure<int>>();

        check(
          Result.guardSync(iWillThrowSynchronously).asFailure.failure,
        ).isA<Exception>();
      });
    });

    group('async', () {
      test('Result from computation: Ok', () async {
        await check(
          Result.guardAsync(iWillReturnAnIntAsynchronously),
        ).completes(
          (result) => result.isA<Ok<int>>(),
        );

        check(
          (await Result.guardAsync(iWillReturnAnIntAsynchronously)).asOk.value,
        ).equals(1);
      });
      test('Result from computation: Failure', () async {
        await check(
          Result.guardAsync(iWillThrowAsynchronously),
        ).completes(
          (result) => result.isA<Failure<int>>(),
        );

        check(
          (await Result.guardAsync(iWillThrowAsynchronously)).asFailure.failure,
        ).isA<Exception>();
      });
    });
  });
}
