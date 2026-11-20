import 'package:fluttea/core/security/attestation/attestation_provider.dart';
import 'package:flutter/services.dart';

final class AppAttestProvider implements DeviceAttestationProvider {
  const new({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('fluttea/app_attest');

  final MethodChannel _channel;

  @override
  String get platformName => 'ios';

  @override
  Future<String?> requestAttestationToken({required String nonce}) async {
    try {
      final token = await _channel.invokeMethod<String>('requestAppAttestToken', {'nonce': nonce});
      return token;
    } on PlatformException {
      return null;
    }
  }
}
