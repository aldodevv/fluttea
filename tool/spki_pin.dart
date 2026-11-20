import 'dart:io';
import 'dart:typed_data';

import 'package:fluttea/core/network/pinning/spki_helper.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stdout.writeln(
      'Usage: dart run tool/spki_pin.dart <host>[:<port>]\n'
      'Example: dart run tool/spki_pin.dart api.example.com:443',
    );
    exit(1);
  }

  final target = args.first;
  final parts = target.split(':');
  final host = parts[0];
  final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 443 : 443;

  stdout.writeln('Connecting to $host:$port via TLS...');

  try {
    final socket = await SecureSocket.connect(
      host,
      port,
      onBadCertificate: (cert) => true,
      timeout: const Duration(seconds: 10),
    );

    final cert = socket.peerCertificate;
    if (cert == null) {
      stderr.writeln('Error: No peer certificate presented by $host');
      await socket.close();
      exit(2);
    }

    final der = Uint8List.fromList(cert.der);
    final spkiPin = SpkiHelper.calculateSpkiPin(der);
    final certFingerprint = SpkiHelper.calculateCertFingerprint(der);

    stdout.write(
      '----------------------------------------------------\n'
      'Subject    : ${cert.subject}\n'
      'Issuer     : ${cert.issuer}\n'
      'Valid From : ${cert.startValidity}\n'
      'Valid Until: ${cert.endValidity}\n'
      '----------------------------------------------------\n'
      'SPKI SHA-256 (Base64) : $spkiPin\n'
      'Cert Fingerprint (Hex): $certFingerprint\n'
      '----------------------------------------------------\n'
      '\nDart PinSet snippet:\n'
      "'$host': PinSet.any([\n"
      "  PinStrategy.spki(spkiSha256Base64: '$spkiPin'),\n"
      '  // TODO: Add backup SPKI pin for rotation\n'
      ']),\n\n',
    );

    await socket.close();
  } on Object catch (e) {
    stderr.writeln('Failed to retrieve certificates from $host:$port -> $e');
    exit(3);
  }
}
