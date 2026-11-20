import 'dart:convert';

import 'package:fluttea/core/security/hashing/hash_registry.dart';
import 'package:fluttea/core/security/hashing/hash_suite.dart';
import 'package:fluttea/core/security/hashing/hmac_signer.dart';
import 'package:fluttea/core/security/hashing/password_kdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HashSuites', () {
    test('Sha256Suite matches standard test vector for "abc"', () async {
      final sha256 = Sha256Suite();
      final hex = await sha256.hashStringHex('abc');
      expect(hex, 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    });

    test('Sha512Suite matches standard test vector for "abc"', () async {
      final sha512 = Sha512Suite();
      final hex = await sha512.hashStringHex('abc');
      expect(
        hex,
        'ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f',
      );
    });

    test('Blake2bSuite produces non-empty digest', () async {
      final blake = Blake2bSuite();
      final hex = await blake.hashStringHex('test');
      expect(hex.isNotEmpty, isTrue);
    });
  });

  group('HashRegistry', () {
    test('contains sha-256, sha-512, blake2b', () {
      final registry = HashRegistry.standard();
      expect(registry.has(Sha256Suite.suiteId), isTrue);
      expect(registry.has(Sha512Suite.suiteId), isTrue);
      expect(registry.has(Blake2bSuite.suiteId), isTrue);
      expect(registry.supportedAlgorithms.length, 3);
    });
  });

  group('HmacSigner', () {
    final signer = HmacSigner();
    final secretKey = List<int>.generate(32, (i) => i + 1);

    test('signs request and generates valid headers', () {
      final signature = signer.sign(
        method: 'POST',
        path: '/v1/cards/pay',
        secretKey: secretKey,
        body: utf8.encode('{"amount": 1000}'),
        timestamp: '2026-11-16T12:00:00Z',
        nonce: 'nonce12345',
      );

      final headers = signature.toHeaders(keyId: 'kid-01');
      expect(headers['X-Signature'], signature.signature);
      expect(headers['X-Timestamp'], '2026-11-16T12:00:00Z');
      expect(headers['X-Nonce'], 'nonce12345');
      expect(headers['X-Key-Id'], 'kid-01');
      expect(headers['X-Body-Hash'], isNotNull);
    });

    test('verify returns true for valid matching signature', () {
      final body = utf8.encode('{"action":"login"}');
      final sig = signer.sign(
        method: 'POST',
        path: '/auth/login',
        secretKey: secretKey,
        body: body,
        timestamp: DateTime.now().toUtc().toIso8601String(),
        nonce: 'n-random-123',
      );

      final valid = signer.verify(
        expectedSignature: sig.signature,
        method: 'POST',
        path: '/auth/login',
        timestamp: sig.timestamp,
        nonce: sig.nonce,
        body: body,
        secretKey: secretKey,
        maxTimeDrift: const Duration(minutes: 5),
      );

      expect(valid, isTrue);
    });

    test('verify returns false when body or path is tampered', () {
      final body = utf8.encode('{"amount": 500}');
      final sig = signer.sign(method: 'POST', path: '/transfer', secretKey: secretKey, body: body);

      final tamperedBody = utf8.encode('{"amount": 5000000}');
      final tamperedValid = signer.verify(
        expectedSignature: sig.signature,
        method: 'POST',
        path: '/transfer',
        timestamp: sig.timestamp,
        nonce: sig.nonce,
        body: tamperedBody,
        secretKey: secretKey,
      );
      expect(tamperedValid, isFalse);
    });

    test('verify returns false when maxTimeDrift is exceeded', () {
      final body = utf8.encode('test');
      final oldTimestamp = DateTime.now()
          .subtract(const Duration(hours: 1))
          .toUtc()
          .toIso8601String();

      final sig = signer.sign(
        method: 'GET',
        path: '/status',
        secretKey: secretKey,
        body: body,
        timestamp: oldTimestamp,
      );

      final valid = signer.verify(
        expectedSignature: sig.signature,
        method: 'GET',
        path: '/status',
        timestamp: oldTimestamp,
        nonce: sig.nonce,
        body: body,
        secretKey: secretKey,
        maxTimeDrift: const Duration(minutes: 5),
      );
      expect(valid, isFalse);
    });
  });

  group('PasswordKdf', () {
    final kdf = PasswordKdf();

    test('Argon2id hashes password and verifies successfully', () async {
      const password = 'CorrectHorseBatteryStaple123!';
      final hash = await kdf.hashPassword(password);

      expect(hash.startsWith(r'$argon2id$'), isTrue);

      final isMatch = await kdf.verifyPassword(password, hash);
      expect(isMatch, isTrue);

      final isWrong = await kdf.verifyPassword('WrongPassword', hash);
      expect(isWrong, isFalse);
    });

    test('Pbkdf2 hashes password and verifies successfully', () async {
      const password = 'FallbackPassword456!';
      final hash = await kdf.hashPassword(password, algorithm: PasswordKdfAlgorithm.pbkdf2Sha256);

      expect(hash.startsWith(r'$pbkdf2$'), isTrue);

      final isMatch = await kdf.verifyPassword(password, hash);
      expect(isMatch, isTrue);

      final isWrong = await kdf.verifyPassword('Incorrect', hash);
      expect(isWrong, isFalse);
    });

    test('verifyPassword returns false for malformed hash string', () async {
      expect(await kdf.verifyPassword('pass', 'bad_hash_without_delimiters'), isFalse);
      expect(await kdf.verifyPassword('pass', r'$unknown$p=1$salt$hash'), isFalse);
    });
  });
}
