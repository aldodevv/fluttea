import 'package:fluttea/core/logging/pii_masker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PiiMasker', () {
    test('masks Bearer tokens', () {
      const input = 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xyz';
      final masked = PiiMasker.maskString(input);
      expect(masked, equals('Authorization: Bearer [REDACTED_TOKEN]'));
    });

    test('masks email addresses', () {
      const input = 'Kontak user: aldo.developer@example.com untuk info';
      final masked = PiiMasker.maskString(input);
      expect(masked, equals('Kontak user: al***@example.com untuk info'));
    });

    test('masks phone numbers', () {
      const input = 'Nomor hp +628123456789 terdaftar';
      final masked = PiiMasker.maskString(input);
      expect(masked, equals('Nomor hp +6281****6789 terdaftar'));
    });

    test('masks sensitive map keys', () {
      final map = {
        'username': 'john_doe',
        'email': 'john@example.com',
        'password': 'SuperSecretPassword123!',
        'token': 'secret-token-abc',
        'profile': {'pin': '123456', 'nickname': 'Johnny'},
        'items': [
          {'cvv': '999', 'name': 'Visa Card'},
          'Contact phone: +628123456789',
        ],
      };

      final masked = PiiMasker.maskMap(map);

      expect(masked['username'], equals('john_doe'));
      expect(masked['password'], equals('[REDACTED]'));
      expect(masked['token'], equals('[REDACTED]'));
      expect((masked['profile'] as Map)['pin'], equals('[REDACTED]'));
      expect((masked['profile'] as Map)['nickname'], equals('Johnny'));
      expect(((masked['items'] as List)[0] as Map)['cvv'], equals('[REDACTED]'));
      expect((masked['items'] as List)[1], contains('+6281****6789'));
    });
  });
}
