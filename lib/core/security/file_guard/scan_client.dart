final class ScanResult {
  const new clean({this.scanId}) : isClean = true, threatName = null;

  const new infected({required this.threatName, this.scanId}) : isClean = false;

  final bool isClean;
  final String? threatName;
  final String? scanId;

  @override
  String toString() => isClean ? 'ScanResult(clean)' : 'ScanResult(infected: $threatName)';
}

abstract interface class MalwareScanClient {
  Future<ScanResult> scanFileHash(String sha256);
  Future<ScanResult> uploadAndScan(List<int> bytes, {required String fileName});
}

final class MockMalwareScanClient implements MalwareScanClient {
  const new({Set<String>? knownMalwareHashes, Set<String>? maliciousFileNames})
    : _knownMalwareHashes = knownMalwareHashes ?? const <String>{},
      _maliciousFileNames = maliciousFileNames ?? const <String>{};

  final Set<String> _knownMalwareHashes;
  final Set<String> _maliciousFileNames;

  @override
  Future<ScanResult> scanFileHash(String sha256) async {
    if (_knownMalwareHashes.contains(sha256.toLowerCase())) {
      return const ScanResult.infected(
        threatName: 'EICAR-Test-Signature',
        scanId: 'mock-scan-hash',
      );
    }
    return const ScanResult.clean(scanId: 'mock-scan-hash');
  }

  @override
  Future<ScanResult> uploadAndScan(List<int> bytes, {required String fileName}) async {
    if (_maliciousFileNames.contains(fileName.toLowerCase())) {
      return const ScanResult.infected(
        threatName: 'Malicious.Pattern.Match',
        scanId: 'mock-scan-upload',
      );
    }
    return const ScanResult.clean(scanId: 'mock-scan-upload');
  }
}
