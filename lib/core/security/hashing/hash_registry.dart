import 'package:fluttea/core/security/hashing/hash_suite.dart';

final class HashRegistry {
  new([Map<String, HashSuite>? suites]) : _suites = suites ?? <String, HashSuite>{};

  factory standard() {
    return HashRegistry()
      ..register(Sha256Suite())
      ..register(Sha512Suite())
      ..register(Blake2bSuite());
  }

  final Map<String, HashSuite> _suites;

  void register(HashSuite suite) {
    _suites[suite.id] = suite;
  }

  HashSuite? find(String id) => _suites[id];

  HashSuite get(String id) {
    final suite = find(id);
    if (suite == null) {
      throw ArgumentError('Unsupported hash suite "$id". Available: ${_suites.keys.join(', ')}');
    }
    return suite;
  }

  bool has(String id) => _suites.containsKey(id);

  List<String> get supportedAlgorithms => List<String>.unmodifiable(_suites.keys);
}
