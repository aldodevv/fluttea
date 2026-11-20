import 'dart:convert';

import 'package:fluttea/core/security/crypto/aes_gcm_suite.dart';
import 'package:fluttea/core/security/crypto/chacha20_suite.dart';
import 'package:fluttea/core/security/crypto/cipher_envelope.dart';
import 'package:fluttea/core/security/crypto/cipher_registry.dart';
import 'package:fluttea/core/security/crypto/key_agreement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final key32 = List<int>.generate(32, (i) => i);
  final invalidKey16 = List<int>.generate(16, (i) => i);

  group('AesGcmSuite', () {
    final suite = AesGcmSuite();

    test('encrypt and decrypt recovers original plaintext', () async {
      const message = 'Halo Fluttea Security!';
      final envelope = await suite.encryptString(message, key: key32, keyId: 'test-key-1');

      expect(envelope.suite, AesGcmSuite.suiteId);
      expect(envelope.keyId, 'test-key-1');
      expect(envelope.nonceBytes.length, 12);
      expect(envelope.tagBytes.length, 16);

      final decrypted = await suite.decryptString(envelope, key: key32);
      expect(decrypted, message);
    });

    test('encrypt with AAD succeeds and fails if AAD is tampered', () async {
      const message = 'Transfer Rp 10.000.000';
      final aad = utf8.encode('account:12345');
      final tamperedAad = utf8.encode('account:99999');

      final envelope = await suite.encryptString(message, key: key32, aad: aad);

      final decrypted = await suite.decryptString(envelope, key: key32, aad: aad);
      expect(decrypted, message);

      // Decryption with wrong AAD must fail
      expect(
        () => suite.decryptString(envelope, key: key32, aad: tamperedAad),
        throwsA(isA<Object>()),
      );
    });

    test('tampered ciphertext or tag fails authentication', () async {
      final envelope = await suite.encryptString('Secret', key: key32);
      final tamperedCt = List<int>.from(envelope.ciphertextBytes);
      tamperedCt[0] ^= 0xFF;

      final corruptedEnvelope = CipherEnvelope.fromBytes(
        suite: envelope.suite,
        nonce: envelope.nonceBytes,
        ciphertext: tamperedCt,
        tag: envelope.tagBytes,
      );

      expect(() => suite.decryptString(corruptedEnvelope, key: key32), throwsA(isA<Object>()));
    });

    test('throws ArgumentError if key is not 32 bytes', () async {
      expect(() => suite.encryptString('Hello', key: invalidKey16), throwsArgumentError);
    });
  });

  group('ChaCha20Suite', () {
    final suite = ChaCha20Suite();

    test('encrypt and decrypt recovers original plaintext', () async {
      const message = 'ChaCha20-Poly1305 AEAD Test';
      final envelope = await suite.encryptString(message, key: key32, keyId: 'chacha-key');

      expect(envelope.suite, ChaCha20Suite.suiteId);
      expect(envelope.keyId, 'chacha-key');
      expect(envelope.nonceBytes.length, 12);
      expect(envelope.tagBytes.length, 16);

      final decrypted = await suite.decryptString(envelope, key: key32);
      expect(decrypted, message);
    });

    test('decrypt with wrong key throws authentication failure', () async {
      final envelope = await suite.encryptString('Message', key: key32);
      final wrongKey = List<int>.generate(32, (i) => 255 - i);

      expect(() => suite.decryptString(envelope, key: wrongKey), throwsA(isA<Object>()));
    });
  });

  group('CipherEnvelope', () {
    test('JSON serialization roundtrip works correctly', () {
      const original = CipherEnvelope(
        suite: 'aes-256-gcm',
        keyId: 'kid-42',
        nonce: 'bm9uY2UxMjM0NTY3',
        ciphertext: 'Y2lwaGVydGV4dGRhdGE=',
        tag: 'dGFnMTIzNDU2Nzg5MA==',
      );

      final json = original.toJson();
      final restored = CipherEnvelope.fromJson(json);

      expect(restored, original);
      expect(restored.hashCode, original.hashCode);
      expect(restored.suite, original.suite);
      expect(restored.keyId, original.keyId);

      final serialized = original.serialize();
      final fromRaw = CipherEnvelope.deserialize(serialized);
      expect(fromRaw, original);
    });
  });

  group('CipherRegistry', () {
    test('standard registry contains AES-GCM and ChaCha20', () {
      final registry = CipherRegistry.standard();
      expect(registry.has(AesGcmSuite.suiteId), isTrue);
      expect(registry.has(ChaCha20Suite.suiteId), isTrue);
      expect(registry.supportedSuites.length, 2);

      final aes = registry.get(AesGcmSuite.suiteId);
      expect(aes, isA<AesGcmSuite>());
    });

    test('throws ArgumentError on unknown suite ID', () {
      final registry = CipherRegistry.standard();
      expect(() => registry.get('des-ede-cbc'), throwsArgumentError);
    });
  });

  group('KeyAgreementService (X25519 ECDH + HKDF)', () {
    final service = KeyAgreementService();

    test('Alice and Bob derive identical shared session keys', () async {
      final aliceKeyPair = await service.generateKeyPair();
      final bobKeyPair = await service.generateKeyPair();

      final alicePub = await service.getPublicKey(aliceKeyPair);
      final bobPub = await service.getPublicKey(bobKeyPair);

      final aliceShared = await service.deriveSharedKey(
        localKeyPair: aliceKeyPair,
        remotePublicKey: bobPub,
        info: utf8.encode('fluttea-session-v1'),
      );

      final bobShared = await service.deriveSharedKey(
        localKeyPair: bobKeyPair,
        remotePublicKey: alicePub,
        info: utf8.encode('fluttea-session-v1'),
      );

      expect(aliceShared.length, 32);
      expect(bobShared.length, 32);
      expect(aliceShared, bobShared);
    });

    test('export and import public key base64', () async {
      final keyPair = await service.generateKeyPair();
      final b64 = await service.exportPublicKeyBase64(keyPair);

      final imported = service.importPublicKeyBase64(b64);
      final expected = await service.getPublicKey(keyPair);
      expect(imported.bytes, expected.bytes);
    });
  });
}
