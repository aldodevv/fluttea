import 'package:cryptography/cryptography.dart';
import 'package:fluttea/core/constants/security/security_consts.dart';
import 'package:fluttea/core/security/crypto/cipher_envelope.dart';
import 'package:fluttea/core/security/crypto/cipher_suite.dart';
import 'package:fluttea/core/security/secure_random.dart';

final class AesGcmSuite extends CipherSuite {
  new({AesGcm? algorithm, AppSecureRandom? secureRandom})
    : _algorithm = algorithm ?? AesGcm.with256bits(),
      _secureRandom = secureRandom ?? AppSecureRandom.instance;

  static const String suiteId = 'aes-256-gcm';

  @override
  String get id => suiteId;

  final AesGcm _algorithm;
  final AppSecureRandom _secureRandom;

  @override
  Future<CipherEnvelope> encrypt(
    List<int> plaintext, {
    required List<int> key,
    List<int>? aad,
    String? keyId,
  }) async {
    _validateKey(key);
    final nonce = _secureRandom.nextBytes(SecurityConsts.nonceLength);
    final secretBox = await _algorithm.encrypt(
      plaintext,
      secretKey: SecretKey(key),
      nonce: nonce,
      aad: aad ?? const <int>[],
    );

    return CipherEnvelope.fromBytes(
      suite: id,
      keyId: keyId,
      nonce: secretBox.nonce,
      ciphertext: secretBox.cipherText,
      tag: secretBox.mac.bytes,
    );
  }

  @override
  Future<List<int>> decrypt(
    CipherEnvelope envelope, {
    required List<int> key,
    List<int>? aad,
  }) async {
    if (envelope.suite != id) {
      throw ArgumentError('Envelope suite "${envelope.suite}" does not match $id');
    }
    _validateKey(key);

    final secretBox = SecretBox(
      envelope.ciphertextBytes,
      nonce: envelope.nonceBytes,
      mac: Mac(envelope.tagBytes),
    );

    return await _algorithm.decrypt(
      secretBox,
      secretKey: SecretKey(key),
      aad: aad ?? const <int>[],
    );
  }

  void _validateKey(List<int> key) {
    if (key.length != SecurityConsts.keyLength256Bits) {
      throw ArgumentError(
        'Key must be ${SecurityConsts.keyLength256Bits} bytes (got ${key.length})',
      );
    }
  }
}
