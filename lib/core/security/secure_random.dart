import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

final class AppSecureRandom {
  new({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  static final AppSecureRandom instance = AppSecureRandom();

  Uint8List nextBytes(int length) {
    if (length <= 0) {
      return Uint8List(0);
    }
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  String nextHex(int byteLength) {
    final bytes = nextBytes(byteLength);
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  String nextBase64(int byteLength, {bool urlSafe = false}) {
    final bytes = nextBytes(byteLength);
    return urlSafe ? base64Url.encode(bytes).replaceAll('=', '') : base64.encode(bytes);
  }

  int nextInt(int min, int max) {
    if (min >= max) {
      throw ArgumentError('min ($min) must be less than max ($max)');
    }
    final range = max - min;
    return min + _random.nextInt(range);
  }

  /// Generates a cryptographically secure RFC 4122 v4 UUID.
  String uuidV4() {
    final bytes = nextBytes(16);

    // Set version to 4 (bits 4-7 to 0100) -> 0x40
    bytes[6] = (bytes[6] & 0x0f) | 0x40;

    // Set variant to RFC 4122 (bits 6-7 to 10) -> 0x80
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        hex.write('-');
      }
      hex.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return hex.toString();
  }
}
