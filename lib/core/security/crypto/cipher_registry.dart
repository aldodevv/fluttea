import 'package:fluttea/core/security/crypto/aes_gcm_suite.dart';
import 'package:fluttea/core/security/crypto/chacha20_suite.dart';
import 'package:fluttea/core/security/crypto/cipher_suite.dart';

final class CipherRegistry {
  new([Map<String, CipherSuite>? suites]) : _suites = suites ?? <String, CipherSuite>{};

  factory standard() {
    return CipherRegistry()
      ..register(AesGcmSuite())
      ..register(ChaCha20Suite());
  }

  final Map<String, CipherSuite> _suites;

  void register(CipherSuite suite) {
    _suites[suite.id] = suite;
  }

  CipherSuite? find(String id) => _suites[id];

  CipherSuite get(String id) {
    final suite = find(id);
    if (suite == null) {
      throw ArgumentError('Unsupported cipher suite "$id". Available: ${_suites.keys.join(', ')}');
    }
    return suite;
  }

  bool has(String id) => _suites.containsKey(id);

  List<String> get supportedSuites => List<String>.unmodifiable(_suites.keys);
}
