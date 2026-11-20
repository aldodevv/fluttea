import 'package:fluttea/core/security/secure_random.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSecureRandom', () {
    final random = AppSecureRandom.instance;

    test('nextBytes generates requested number of bytes', () {
      final bytes0 = random.nextBytes(0);
      expect(bytes0.length, 0);

      final bytes16 = random.nextBytes(16);
      expect(bytes16.length, 16);

      final bytes32 = random.nextBytes(32);
      expect(bytes32.length, 32);
      // Non-zero entropy test
      expect(bytes32.any((b) => b != 0), isTrue);
    });

    test('nextHex generates valid hex string with length 2 * byteLength', () {
      final hex = random.nextHex(16);
      expect(hex.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(hex), isTrue);
    });

    test('nextBase64 generates valid base64', () {
      final b64 = random.nextBase64(16);
      expect(b64.isNotEmpty, isTrue);

      final urlSafe = random.nextBase64(16, urlSafe: true);
      expect(urlSafe.contains('+'), isFalse);
      expect(urlSafe.contains('/'), isFalse);
      expect(urlSafe.contains('='), isFalse);
    });

    test('nextInt generates integers strictly within bounds', () {
      for (var i = 0; i < 50; i++) {
        final val = random.nextInt(10, 20);
        expect(val, greaterThanOrEqualTo(10));
        expect(val, lessThan(20));
      }
    });

    test('uuidV4 generates compliant RFC 4122 UUID v4', () {
      final uuid = random.uuidV4();
      expect(uuid.length, 36);

      // Regex for RFC 4122 v4
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidRegex.hasMatch(uuid), isTrue);

      // Verify uniqueness across 100 generations
      final set = <String>{};
      for (var i = 0; i < 100; i++) {
        set.add(random.uuidV4());
      }
      expect(set.length, 100);
    });
  });
}
