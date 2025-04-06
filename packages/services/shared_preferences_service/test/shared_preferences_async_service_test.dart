import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_service/shared_preferences_async_service.dart';
import 'package:shared_preferences_service_test/fake_shared_preferences_async.dart';
import 'package:shared_preferences_service_test/get_preferences.dart';

void main() {
  late SharedPreferencesAsync sharedPreferencesAsync;
  late SharedPreferencesAsyncService service;
  late FakeSharedPreferencesAsync store;

  setUp(() {
    (sharedPreferencesAsync, store) = getPreferences();
    service = SharedPreferencesAsyncService(sharedPreferencesAsync);
  });

  tearDown(() {
    sharedPreferencesAsync.clear();
    store.log.clear();
  });

  group('sharedPreferencesAsyncService', () {
    test('containsKey', () async {
      final sampleKey = faker.lorem.word();
      final result = await service.containsKey(sampleKey);

      expect(result, await sharedPreferencesAsync.containsKey(sampleKey));
    });

    test('getString (with an already existent value)', () async {
      final sampleKey = faker.lorem.word();
      final sampleValue = faker.lorem.word();

      await sharedPreferencesAsync.setString(sampleKey, sampleValue);

      final result = await service.getString(sampleKey);

      expect(
        store.log,
        containsOnce(isMethodCall('getString', arguments: [sampleKey])),
      );

      expect(result, equals(sampleValue));
    });

    test('getString (without an existent value)', () async {
      final sampleKey = faker.lorem.word();

      final inexistentValueFromService = await service.getString(sampleKey);

      expect(
        store.log,
        containsOnce(isMethodCall('getString', arguments: [sampleKey])),
      );

      final inexistentValueFromSharedPreferences = await sharedPreferencesAsync
          .getString(sampleKey);

      expect(inexistentValueFromService, inexistentValueFromSharedPreferences);
      expect(inexistentValueFromService, isNull);
      expect(inexistentValueFromSharedPreferences, isNull);
    });

    test('setString', () async {
      final sampleKey = faker.lorem.word();
      final sampleValue = faker.lorem.word();

      await service.setString(sampleKey, sampleValue);

      expect(store.log, <Matcher>[
        isMethodCall('setString', arguments: [sampleKey, sampleValue]),
      ]);

      final containsKey = await service.containsKey(sampleKey);

      expect(containsKey, await sharedPreferencesAsync.containsKey(sampleKey));
    });
  });
}
