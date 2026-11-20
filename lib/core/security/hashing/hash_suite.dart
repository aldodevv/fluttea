import 'dart:convert';

import 'package:cryptography/cryptography.dart' as crypto_pkg;

abstract class HashSuite {
  const new();

  String get id;

  Future<List<int>> hash(List<int> data);

  Future<String> hashHex(List<int> data) async {
    final digest = await hash(data);
    final buffer = StringBuffer();
    for (final b in digest) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  Future<String> hashStringHex(String text) => hashHex(utf8.encode(text));
}

final class Sha256Suite extends HashSuite {
  new({crypto_pkg.Sha256? algorithm}) : _algorithm = algorithm ?? crypto_pkg.Sha256();

  static const String suiteId = 'sha-256';

  @override
  String get id => suiteId;

  final crypto_pkg.Sha256 _algorithm;

  @override
  Future<List<int>> hash(List<int> data) async {
    final result = await _algorithm.hash(data);
    return result.bytes;
  }
}

final class Sha512Suite extends HashSuite {
  new({crypto_pkg.Sha512? algorithm}) : _algorithm = algorithm ?? crypto_pkg.Sha512();

  static const String suiteId = 'sha-512';

  @override
  String get id => suiteId;

  final crypto_pkg.Sha512 _algorithm;

  @override
  Future<List<int>> hash(List<int> data) async {
    final result = await _algorithm.hash(data);
    return result.bytes;
  }
}

final class Blake2bSuite extends HashSuite {
  new({crypto_pkg.Blake2b? algorithm}) : _algorithm = algorithm ?? crypto_pkg.Blake2b();

  static const String suiteId = 'blake2b';

  @override
  String get id => suiteId;

  final crypto_pkg.Blake2b _algorithm;

  @override
  Future<List<int>> hash(List<int> data) async {
    final result = await _algorithm.hash(data);
    return result.bytes;
  }
}
