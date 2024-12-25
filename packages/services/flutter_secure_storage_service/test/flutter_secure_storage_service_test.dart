import 'package:faker/faker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_service/flutter_secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FlutterSecureStorageService secureStorageService;
  const flutterSecureStorage = FlutterSecureStorage();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    secureStorageService = const FlutterSecureStorageService(
      flutterSecureStorage: flutterSecureStorage,
    );
  });

  tearDown(() {
    flutterSecureStorage.deleteAll();
  });

  group('containsKey', () {
    final sampleKey = faker.lorem.word();
    final sampleValue = faker.lorem.word();
    group('with already existent key', () {
      setUp(() {
        FlutterSecureStorage.setMockInitialValues({sampleKey: sampleValue});
      });

      test('should return true', () {
        expect(secureStorageService.containsKey(sampleKey), completion(isTrue));
      });
    });

    group('without an existent key', () {
      test('should return false', () {
        expect(
          secureStorageService.containsKey(sampleKey),
          completion(isFalse),
        );
      });
    });
  });

  group('read', () {
    final sampleKey = faker.lorem.word();
    final sampleValue = faker.lorem.word();
    group('with an existent value', () {
      setUp(() {
        FlutterSecureStorage.setMockInitialValues({sampleKey: sampleValue});
      });
      test('should return it', () {
        expect(
          secureStorageService.read(sampleKey),
          completion(equals(sampleValue)),
        );
      });
    });

    group('without an existent value', () {
      test('should return null', () {
        expect(
          secureStorageService.read(sampleKey),
          completion(isNull),
        );
      });
    });
  });

  group('write', () {
    final sampleKey = faker.lorem.word();
    final sampleValue1 = faker.lorem.word();
    final sampleValue2 = faker.lorem.word();

    assert(sampleValue1 != sampleValue2, 'Cannot be same samples');
    group('with an existent value', () {
      setUp(() {
        FlutterSecureStorage.setMockInitialValues({sampleKey: sampleValue1});
      });

      test('should overwrite', () async {
        expect(
          secureStorageService.read(sampleKey),
          completion(equals(sampleValue1)),
        );

        await secureStorageService.write(sampleKey, sampleValue2);

        expect(
          secureStorageService.read(sampleKey),
          completion(
            allOf([
              isNot(sampleValue1),
              equals(sampleValue2),
            ]),
          ),
        );
      });
    });
  });
}
