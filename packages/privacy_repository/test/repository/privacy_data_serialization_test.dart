import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_repository/logic/models/privacy_data.dart';
import 'package:privacy_repository/logic/models/privacy_data_errors.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotify_utils/quotify_utils.dart';

void main() {
  const seed = 32;
  final random = Random(seed);

  late PrivacyData privacyData;

  setUp(() {
    privacyData = PrivacyData(
      acceptedDataUsage: random.nextBool(),
      allowErrorReporting: random.nextBool(),
    );
  });

  group('toMap', () {
    test('should contain both keys and values', () {
      final map = privacyData.toMap();

      expect(
        map,
        containsPair(
          PrivacyRepository.allowErrorReportingKey,
          privacyData.allowErrorReporting,
        ),
      );
      expect(
        map,
        containsPair(
          PrivacyRepository.acceptedDataUsageKey,
          privacyData.acceptedDataUsage,
        ),
      );
    });
  });

  group('fromMap', () {
    group('with correct map', () {
      test(
        'should return Ok with privacy data',
        () {
          final map = privacyData.toMap();

          final result = PrivacyData.fromMap(map);

          expect(result, isA<Ok<PrivacyData>>());
          expect(result.asOk.value, equals(privacyData));
        },
      );
    });

    group('with invalid map', () {
      const sampleMap = <String, Object?>{};

      test(
        'should return Failure with PrivacyDataErrors.invalidMapFormat',
        () {
          final result = PrivacyData.fromMap(sampleMap);
          expect(result, isA<Failure<PrivacyData>>());
          expect(
            (result as Failure<PrivacyData>).failure,
            equals(PrivacyDataErrors.invalidMapFormat),
          );
        },
      );
    });
  });

  group('toJsonString', () {
    test('should be decodable as Map', () {
      expect(
        jsonDecode(privacyData.toJsonString()),
        isA<Map<String, Object?>>(),
      );
    });
  });

  group('fromJsonString', () {
    group('with invalid json string', () {
      const sampleMap = <String, Object?>{};
      final sampleList = <Map<String, Object?>>[
        for (var i = 0; i < 5; i++) {'$i': i},
      ];

      test(
        'should return a Failure with PrivacyDataErrors.invalidJsonStringFormat',
        () {
          for (final sample in [sampleMap, sampleList].map(jsonEncode)) {
            final result = PrivacyData.fromJsonString(sample);
            expect(
              result,
              isA<Failure<PrivacyData>>(),
            );
            expect(
              result.asFailure.failure,
              isA<PrivacyDataErrors>(),
            );
          }
        },
      );
    });

    group('with valid json string', () {
      test('should return an instance of Ok with the Privacy data', () {
        final jsonString = privacyData.toJsonString();

        final result = PrivacyData.fromJsonString(jsonString);

        expect(result, isA<Ok<PrivacyData>>());
        expect(result.asOk.value, privacyData);
      });
    });
  });
}
