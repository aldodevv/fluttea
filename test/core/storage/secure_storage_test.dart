import 'package:fluttea/core/storage/secure/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage;

void main() {
  group('SecureStorage', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorage secureStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      secureStorage = SecureStorage(storage: mockStorage);
    });

    test('read returns value from storage', () async {
      when(() => mockStorage.read(key: 'token')).thenAnswer((_) async => 'secret_val');

      final result = await secureStorage.read('token');
      expect(result, equals('secret_val'));
      verify(() => mockStorage.read(key: 'token')).called(1);
    });

    test('write passes key and value to storage', () async {
      when(() => mockStorage.write(key: 'token', value: 'secret_val')).thenAnswer((_) async {});

      await secureStorage.write('token', 'secret_val');
      verify(() => mockStorage.write(key: 'token', value: 'secret_val')).called(1);
    });

    test('delete calls storage delete', () async {
      when(() => mockStorage.delete(key: 'token')).thenAnswer((_) async {});

      await secureStorage.delete('token');
      verify(() => mockStorage.delete(key: 'token')).called(1);
    });

    test('containsKey checks key presence', () async {
      when(() => mockStorage.containsKey(key: 'token')).thenAnswer((_) async => true);

      final exists = await secureStorage.containsKey('token');
      expect(exists, isTrue);
      verify(() => mockStorage.containsKey(key: 'token')).called(1);
    });

    test('deleteAll clears all items', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

      await secureStorage.deleteAll();
      verify(() => mockStorage.deleteAll()).called(1);
    });

    test('readAll returns map of all entries', () async {
      when(() => mockStorage.readAll()).thenAnswer((_) async => {'k1': 'v1', 'k2': 'v2'});

      final all = await secureStorage.readAll();
      expect(all, equals({'k1': 'v1', 'k2': 'v2'}));
      verify(() => mockStorage.readAll()).called(1);
    });
  });
}
