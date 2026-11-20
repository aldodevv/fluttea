import 'dart:convert';

import 'package:fluttea/core/security/crypto/cipher_envelope.dart';

abstract class CipherSuite {
  const new();

  String get id;

  Future<CipherEnvelope> encrypt(
    List<int> plaintext, {
    required List<int> key,
    List<int>? aad,
    String? keyId,
  });

  Future<List<int>> decrypt(CipherEnvelope envelope, {required List<int> key, List<int>? aad});

  Future<CipherEnvelope> encryptString(
    String plaintext, {
    required List<int> key,
    List<int>? aad,
    String? keyId,
  }) => encrypt(utf8.encode(plaintext), key: key, aad: aad, keyId: keyId);

  Future<String> decryptString(
    CipherEnvelope envelope, {
    required List<int> key,
    List<int>? aad,
  }) async {
    final bytes = await decrypt(envelope, key: key, aad: aad);
    return utf8.decode(bytes);
  }
}
