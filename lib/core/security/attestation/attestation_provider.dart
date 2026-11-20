abstract interface class DeviceAttestationProvider {
  Future<String?> requestAttestationToken({required String nonce});
  String get platformName;
}

final class MockDeviceAttestationProvider implements DeviceAttestationProvider {
  const new({this.platformName = 'mock', this.tokenPrefix = 'mock_token'});

  @override
  final String platformName;
  final String tokenPrefix;

  @override
  Future<String?> requestAttestationToken({required String nonce}) async {
    return '${tokenPrefix}_${platformName}_$nonce';
  }
}
