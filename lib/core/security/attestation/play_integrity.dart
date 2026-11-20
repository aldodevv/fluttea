import 'package:fluttea/core/security/attestation/attestation_provider.dart';
import 'package:flutter/services.dart';

final class PlayIntegrityProvider implements DeviceAttestationProvider {
  const new({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('fluttea/play_integrity');

  final MethodChannel _channel;

  @override
  String get platformName => 'android';

  @override
  Future<String?> requestAttestationToken({required String nonce}) async {
    try {
      final token = await _channel.invokeMethod<String>('requestIntegrityToken', {'nonce': nonce});
      return token;
    } on PlatformException {
      return null;
    }
  }
}
