import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto_base;
import 'package:fluttea/core/security/secure_random.dart';

final class HmacRequestSignature {
  const new({
    required this.signature,
    required this.timestamp,
    required this.nonce,
    required this.bodyHash,
  });

  final String signature;
  final String timestamp;
  final String nonce;
  final String bodyHash;

  Map<String, String> toHeaders({String? keyId}) => {
    'X-Signature': signature,
    'X-Timestamp': timestamp,
    'X-Nonce': nonce,
    'X-Body-Hash': bodyHash,
    'X-Key-Id': ?keyId,
  };
}

final class HmacSigner {
  new({AppSecureRandom? secureRandom}) : _secureRandom = secureRandom ?? AppSecureRandom.instance;

  final AppSecureRandom _secureRandom;

  String computeBodyHash(List<int> body) {
    return crypto_base.sha256.convert(body).toString();
  }

  String buildCanonicalString({
    required String method,
    required String path,
    required String timestamp,
    required String nonce,
    required String bodyHash,
  }) {
    return '${method.toUpperCase()}\n$path\n$timestamp\n$nonce\n$bodyHash';
  }

  HmacRequestSignature sign({
    required String method,
    required String path,
    required List<int> secretKey,
    List<int>? body,
    String? timestamp,
    String? nonce,
  }) {
    final effectiveTimestamp = timestamp ?? DateTime.now().toUtc().toIso8601String();
    final effectiveNonce = nonce ?? _secureRandom.nextHex(16);
    final bodyHash = computeBodyHash(body ?? const <int>[]);

    final canonical = buildCanonicalString(
      method: method,
      path: path,
      timestamp: effectiveTimestamp,
      nonce: effectiveNonce,
      bodyHash: bodyHash,
    );

    final hmac = crypto_base.Hmac(crypto_base.sha256, secretKey);
    final digest = hmac.convert(utf8.encode(canonical));

    return HmacRequestSignature(
      signature: digest.toString(),
      timestamp: effectiveTimestamp,
      nonce: effectiveNonce,
      bodyHash: bodyHash,
    );
  }

  bool verify({
    required String expectedSignature,
    required String method,
    required String path,
    required String timestamp,
    required String nonce,
    required List<int> body,
    required List<int> secretKey,
    Duration? maxTimeDrift,
  }) {
    if (maxTimeDrift != null) {
      final parsedTime = DateTime.tryParse(timestamp);
      if (parsedTime == null) return false;
      final diff = DateTime.now().toUtc().difference(parsedTime.toUtc()).abs();
      if (diff > maxTimeDrift) return false;
    }

    final computed = sign(
      method: method,
      path: path,
      secretKey: secretKey,
      body: body,
      timestamp: timestamp,
      nonce: nonce,
    );

    return _constantTimeEquals(expectedSignature, computed.signature);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
