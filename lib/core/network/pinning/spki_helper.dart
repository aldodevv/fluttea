import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';

abstract final class SpkiHelper {
  /// Mengekstrak SubjectPublicKeyInfo (SPKI) dari sertifikat DER dan menghitung SHA-256 Base64 hash.
  static String calculateSpkiPin(Uint8List derBytes) {
    final spkiBytes = extractSpki(derBytes);
    final digest = sha256.convert(spkiBytes);
    return base64.encode(digest.bytes);
  }

  /// Menghitung SHA-256 fingerprint dari seluruh DER sertifikat (hex lowercase).
  static String calculateCertFingerprint(Uint8List derBytes) {
    return sha256.convert(derBytes).toString().toLowerCase();
  }

  /// Mengekstrak byte SubjectPublicKeyInfo dari ASN.1 Sequence sertifikat.
  static Uint8List extractSpki(Uint8List derBytes) {
    try {
      final parser = ASN1Parser(derBytes);
      final certSeq = parser.nextObject() as ASN1Sequence;
      final tbsSeq = certSeq.elements[0] as ASN1Sequence;

      // Elemen pertama TBSCertificate bisa jadi version (explicit tag [0])
      final hasVersion = tbsSeq.elements.isNotEmpty && tbsSeq.elements[0].tag == 0xA0;
      // Index SPKI dalam TBSCertificate:
      // index 6 bila ada version, index 5 bila version di-omit (v1)
      final spkiIndex = hasVersion ? 6 : 5;

      if (tbsSeq.elements.length > spkiIndex) {
        final spkiObj = tbsSeq.elements[spkiIndex];
        return Uint8List.fromList(spkiObj.encodedBytes);
      }
    } on Object {
      // Fallback: jika parsing struktur TBS gagal, gunakan hash dari DER utuh
    }
    return derBytes;
  }
}
