import 'dart:io';

import 'package:fluttea/core/network/pinning/spki_helper.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class PinStrategy {
  const new();

  const factory spki(Set<String> pins) = _SpkiLeafPin;
  const factory certLeaf(Set<String> fingerprints) = _CertLeafPin;
  const factory ca(List<Uint8List> trustedCaDerBytes) = _CaPin;
  const factory off() = _PinOff;

  bool evaluate(X509Certificate certificate);

  List<Uint8List> get trustedCaBytes => switch (this) {
    _CaPin(:final trustedCaDerBytes) => trustedCaDerBytes,
    _ => const [],
  };
}

final class _SpkiLeafPin extends PinStrategy {
  const new(this.pins);

  final Set<String> pins;

  @override
  bool evaluate(X509Certificate certificate) {
    if (pins.isEmpty) return false;
    final pin = SpkiHelper.calculateSpkiPin(Uint8List.fromList(certificate.der));
    return pins.contains(pin);
  }

  @override
  String toString() => '_SpkiLeafPin(pins: $pins)';
}

final class _CertLeafPin extends PinStrategy {
  const new(this.fingerprints);

  final Set<String> fingerprints;

  @override
  bool evaluate(X509Certificate certificate) {
    if (fingerprints.isEmpty) return false;
    final fp = SpkiHelper.calculateCertFingerprint(Uint8List.fromList(certificate.der));
    final normalized = fingerprints.map((e) => e.replaceAll(':', '').toLowerCase()).toSet();
    return normalized.contains(fp);
  }

  @override
  String toString() => '_CertLeafPin(fingerprints: $fingerprints)';
}

final class _CaPin extends PinStrategy {
  const new(this.trustedCaDerBytes);

  final List<Uint8List> trustedCaDerBytes;

  @override
  bool evaluate(X509Certificate certificate) {
    // Evaluasi rantai CA dilakukan di level SecurityContext
    return true;
  }

  @override
  String toString() => '_CaPin(count: ${trustedCaDerBytes.length})';
}

final class _PinOff extends PinStrategy {
  const new();

  @override
  bool evaluate(X509Certificate certificate) => true;

  @override
  String toString() => '_PinOff()';
}
