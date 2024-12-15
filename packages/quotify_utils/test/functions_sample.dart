int iWillThrowSynchronously() => throw Exception();
Future<int> iWillThrowAsynchronously() async => throw Exception();

int iWillReturnAnIntSynchronously() => 1;
Future<int> iWillReturnAnIntAsynchronously() => Future.value(1);
