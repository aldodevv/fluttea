import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:fluttea/core/constants/security/security_consts.dart';
import 'package:fluttea/core/security/secure_random.dart';

enum PasswordKdfAlgorithm { argon2id, pbkdf2Sha256 }

final class PasswordKdf {
  new({AppSecureRandom? secureRandom}) : _secureRandom = secureRandom ?? AppSecureRandom.instance;

  final AppSecureRandom _secureRandom;

  Future<List<int>> deriveKeyWithArgon2id({
    required String password,
    required List<int> salt,
    int memorySize = SecurityConsts.argon2MemorySizeInKib,
    int iterations = SecurityConsts.argon2Iterations,
    int parallelism = SecurityConsts.argon2Parallelism,
    int hashLength = SecurityConsts.argon2HashLength,
  }) async {
    final argon2 = Argon2id(
      parallelism: parallelism,
      memory: memorySize,
      iterations: iterations,
      hashLength: hashLength,
    );

    final secretKey = SecretKey(utf8.encode(password));
    final derived = await argon2.deriveKey(secretKey: secretKey, nonce: salt);
    return await derived.extractBytes();
  }

  Future<List<int>> deriveKeyWithPbkdf2({
    required String password,
    required List<int> salt,
    int iterations = SecurityConsts.pbkdf2Iterations,
    int keyLength = SecurityConsts.keyLength256Bits,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac(Sha256()),
      iterations: iterations,
      bits: keyLength * 8,
    );

    final secretKey = SecretKey(utf8.encode(password));
    final derived = await pbkdf2.deriveKey(secretKey: secretKey, nonce: salt);
    return await derived.extractBytes();
  }

  Future<String> hashPassword(
    String password, {
    PasswordKdfAlgorithm algorithm = PasswordKdfAlgorithm.argon2id,
    List<int>? salt,
  }) async {
    final effectiveSalt = salt ?? _secureRandom.nextBytes(SecurityConsts.saltLength);
    final saltB64 = base64.encode(effectiveSalt);

    switch (algorithm) {
      case PasswordKdfAlgorithm.argon2id:
        final hash = await deriveKeyWithArgon2id(password: password, salt: effectiveSalt);
        final hashB64 = base64.encode(hash);
        return '\$argon2id\$m=${SecurityConsts.argon2MemorySizeInKib},'
            't=${SecurityConsts.argon2Iterations},'
            'p=${SecurityConsts.argon2Parallelism}\$'
            '$saltB64\$$hashB64';

      case PasswordKdfAlgorithm.pbkdf2Sha256:
        final hash = await deriveKeyWithPbkdf2(password: password, salt: effectiveSalt);
        final hashB64 = base64.encode(hash);
        return '\$pbkdf2\$i=${SecurityConsts.pbkdf2Iterations}\$'
            '$saltB64\$$hashB64';
    }
  }

  Future<bool> verifyPassword(String password, String encodedHash) async {
    final parts = encodedHash.split(r'$');
    if (parts.length < 5) return false;

    final type = parts[1];
    final params = parts[2];
    final salt = base64.decode(parts[3]);
    final expectedHash = parts[4];

    if (type == 'argon2id') {
      final paramMap = _parseParams(params);
      final m = paramMap['m'] ?? SecurityConsts.argon2MemorySizeInKib;
      final t = paramMap['t'] ?? SecurityConsts.argon2Iterations;
      final p = paramMap['p'] ?? SecurityConsts.argon2Parallelism;

      final actual = await deriveKeyWithArgon2id(
        password: password,
        salt: salt,
        memorySize: m,
        iterations: t,
        parallelism: p,
      );
      return _constantTimeEquals(expectedHash, base64.encode(actual));
    } else if (type == 'pbkdf2') {
      final paramMap = _parseParams(params);
      final i = paramMap['i'] ?? SecurityConsts.pbkdf2Iterations;

      final actual = await deriveKeyWithPbkdf2(password: password, salt: salt, iterations: i);
      return _constantTimeEquals(expectedHash, base64.encode(actual));
    }

    return false;
  }

  Map<String, int> _parseParams(String raw) {
    final result = <String, int>{};
    for (final pair in raw.split(',')) {
      final kv = pair.split('=');
      if (kv.length == 2) {
        final val = int.tryParse(kv[1]);
        if (val != null) result[kv[0]] = val;
      }
    }
    return result;
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
