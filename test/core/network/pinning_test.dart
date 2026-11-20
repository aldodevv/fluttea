import 'dart:io';
import 'dart:typed_data';

import 'package:fluttea/core/network/pinning/pin_set.dart';
import 'package:fluttea/core/network/pinning/pin_strategy.dart';
import 'package:fluttea/core/network/pinning/pinned_http_client_factory.dart';
import 'package:fluttea/core/network/pinning/spki_helper.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCertificate implements X509Certificate {
  const new(this.bytes);

  final Uint8List bytes;

  @override
  Uint8List get der => bytes;

  @override
  Uint8List get sha1 => Uint8List(20);

  @override
  DateTime get endValidity => DateTime.now().add(const Duration(days: 30));

  @override
  String get issuer => 'CN=Test CA';

  @override
  DateTime get startValidity => DateTime.now().subtract(const Duration(days: 1));

  @override
  String get subject => 'CN=test.example.com';

  @override
  String get pem => '-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----';
}

void main() {
  group('Certificate Pinning', () {
    final sampleDer = Uint8List.fromList([
      0x30,
      0x10,
      0x02,
      0x01,
      0x01,
      0x04,
      0x08,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
    ]);
    final cert = FakeCertificate(sampleDer);

    test('SpkiHelper calculates valid hashes from DER bytes', () {
      final spki = SpkiHelper.calculateSpkiPin(sampleDer);
      final fp = SpkiHelper.calculateCertFingerprint(sampleDer);

      expect(spki, isNotEmpty);
      expect(fp, isNotEmpty);
      expect(fp.length, equals(64)); // SHA-256 hex string length
    });

    test('PinStrategy.spki matches expected SPKI pin', () {
      final expectedPin = SpkiHelper.calculateSpkiPin(sampleDer);
      final strategy = PinStrategy.spki({expectedPin});

      expect(strategy.evaluate(cert), isTrue);

      const wrongStrategy = PinStrategy.spki({'wrong_base64_pin'});
      expect(wrongStrategy.evaluate(cert), isFalse);
    });

    test('PinStrategy.certLeaf matches expected cert fingerprint', () {
      final expectedFp = SpkiHelper.calculateCertFingerprint(sampleDer);
      final strategy = PinStrategy.certLeaf({expectedFp});

      expect(strategy.evaluate(cert), isTrue);

      const wrongStrategy = PinStrategy.certLeaf({'0011223344'});
      expect(wrongStrategy.evaluate(cert), isFalse);
    });

    test('PinSet evaluates host rules correctly', () {
      final expectedPin = SpkiHelper.calculateSpkiPin(sampleDer);
      final pinSet = PinSet(
        rules: {
          'api.example.com': PinStrategy.spki({expectedPin}),
        },
      );

      expect(pinSet.matches(cert, 'api.example.com', 443), isTrue);
      // Host tidak ada dalam rules -> failClosed = tolak
      expect(pinSet.matches(cert, 'other.example.com', 443), isFalse);
    });

    test('PinSet with failClosed: false permits unlisted hosts in dev', () {
      const pinSet = PinSet(failClosed: false);
      expect(pinSet.matches(cert, 'unlisted.example.com', 443), isTrue);
    });

    test('PinnedHttpClientFactory creates adapter with pin set', () {
      const pinSet = PinSet();
      final adapter = PinnedHttpClientFactory.createAdapter(pinSet: pinSet, pinningEnabled: false);
      expect(adapter, isNotNull);
    });
  });
}
