import 'package:drift_database_service/src/utils/uri_to_nullable_string_converter.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = UriToNullableStringConverter();
  group('from nullable String (fromSql)', () {
    test('when null returns null', () {
      expect(converter.fromSql(null), isNull);
    });

    test('when string, returns Uri.tryParse result', () {
      final someString = faker.lorem.word();
      expect(converter.fromSql(someString), Uri.tryParse(someString));

      final httpUri = faker.internet.httpUrl();
      expect(converter.fromSql(httpUri), Uri.tryParse(httpUri));

      final httpsUri = faker.internet.httpsUrl();
      expect(converter.fromSql(httpsUri), Uri.tryParse(httpsUri));
    });
  });

  group('from nullable Uri (toSql)', () {
    test('when null, returns null', () {
      expect(converter.toSql(null), isNull);
    });

    test('when Uri, return Uri.toString', () {
      final uri = Uri.parse(faker.internet.httpsUrl());

      expect(converter.toSql(uri), uri.toString());
    });
  });
}
