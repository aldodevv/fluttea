import 'dart:convert';

import 'package:fluttea/core/constants/security/security_consts.dart';
import 'package:flutter/foundation.dart';

@immutable
final class CipherEnvelope {
  const new({
    required this.suite,
    required this.nonce,
    required this.ciphertext,
    required this.tag,
    this.version = SecurityConsts.defaultEnvelopeVersion,
    this.keyId,
  });

  factory fromBytes({
    required String suite,
    required List<int> nonce,
    required List<int> ciphertext,
    required List<int> tag,
    int version = SecurityConsts.defaultEnvelopeVersion,
    String? keyId,
  }) {
    return CipherEnvelope(
      suite: suite,
      nonce: base64.encode(nonce),
      ciphertext: base64.encode(ciphertext),
      tag: base64.encode(tag),
      version: version,
      keyId: keyId,
    );
  }

  factory fromJson(Map<String, dynamic> json) {
    return CipherEnvelope(
      suite: json['suite'] as String,
      nonce: json['nonce'] as String,
      ciphertext: json['ct'] as String,
      tag: json['tag'] as String,
      version: json['v'] as int? ?? SecurityConsts.defaultEnvelopeVersion,
      keyId: json['kid'] as String?,
    );
  }

  factory deserialize(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return CipherEnvelope.fromJson(decoded);
  }

  final int version;
  final String suite;
  final String? keyId;
  final String nonce;
  final String ciphertext;
  final String tag;

  Uint8List get nonceBytes => base64.decode(nonce);
  Uint8List get ciphertextBytes => base64.decode(ciphertext);
  Uint8List get tagBytes => base64.decode(tag);

  Map<String, dynamic> toJson() => {
    'v': version,
    'suite': suite,
    if (keyId != null) 'kid': keyId,
    'nonce': nonce,
    'ct': ciphertext,
    'tag': tag,
  };

  String serialize() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CipherEnvelope &&
        other.version == version &&
        other.suite == suite &&
        other.keyId == keyId &&
        other.nonce == nonce &&
        other.ciphertext == ciphertext &&
        other.tag == tag;
  }

  @override
  int get hashCode => Object.hash(version, suite, keyId, nonce, ciphertext, tag);

  @override
  String toString() =>
      'CipherEnvelope(v: $version, suite: $suite, kid: $keyId, ct_len: ${ciphertext.length})';
}
