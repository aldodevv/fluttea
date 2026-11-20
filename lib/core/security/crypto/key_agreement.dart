import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:fluttea/core/constants/security/security_consts.dart';

final class KeyAgreementService {
  new({X25519? x25519}) : _x25519 = x25519 ?? X25519();

  final X25519 _x25519;

  Future<SimpleKeyPair> generateKeyPair() => _x25519.newKeyPair();

  Future<SimplePublicKey> getPublicKey(SimpleKeyPair keyPair) => keyPair.extractPublicKey();

  Future<String> exportPublicKeyBase64(SimpleKeyPair keyPair) async {
    final pk = await keyPair.extractPublicKey();
    return base64.encode(pk.bytes);
  }

  SimplePublicKey importPublicKeyBase64(String base64Key) {
    final bytes = base64.decode(base64Key);
    return SimplePublicKey(bytes, type: KeyPairType.x25519);
  }

  SimplePublicKey importPublicKeyBytes(List<int> bytes) {
    return SimplePublicKey(bytes, type: KeyPairType.x25519);
  }

  Future<List<int>> deriveSharedKey({
    required SimpleKeyPair localKeyPair,
    required PublicKey remotePublicKey,
    List<int>? salt,
    List<int>? info,
    int keyLength = SecurityConsts.keyLength256Bits,
  }) async {
    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: localKeyPair,
      remotePublicKey: remotePublicKey,
    );

    final hkdf = Hkdf(hmac: Hmac(Sha256()), outputLength: keyLength);

    final derived = await hkdf.deriveKey(
      secretKey: sharedSecret,
      nonce: salt ?? const <int>[],
      info: info ?? const <int>[],
    );

    return await derived.extractBytes();
  }
}
