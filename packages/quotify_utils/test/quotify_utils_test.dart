import 'package:quotify_utils/quotify_utils.dart';
import 'package:test/test.dart';

int iWillThrowSynchronously() => throw Exception();
Future<int> iWillThrowAsynchronously() async => throw Exception();

int iWillReturnAnIntSynchronously() => 1;
Future<int> iWillReturnAnIntAsynchronously() => Future.value(1);

void main() {
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
}
