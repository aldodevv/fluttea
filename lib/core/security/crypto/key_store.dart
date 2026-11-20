import 'dart:convert';
import 'dart:typed_data';

import 'package:fluttea/core/storage/secure/secure_storage.dart';

abstract interface class SecurityKeyStore {
  Future<void> saveKey(String keyId, List<int> keyBytes);
  Future<Uint8List?> loadKey(String keyId);
  Future<bool> hasKey(String keyId);
  Future<void> deleteKey(String keyId);
  Future<void> clearAllKeys();
}

final class SecureStorageKeyStore implements SecurityKeyStore {
  const new({SecureStorage? storage}) : _storage = storage ?? const SecureStorage();

  static const String _keyPrefix = 'fluttea_sec_key_';

  final SecureStorage _storage;

  String _formatKey(String keyId) => '$_keyPrefix$keyId';

  @override
  Future<void> saveKey(String keyId, List<int> keyBytes) async {
    final encoded = base64.encode(keyBytes);
    await _storage.write(_formatKey(keyId), encoded);
  }

  @override
  Future<Uint8List?> loadKey(String keyId) async {
    final encoded = await _storage.read(_formatKey(keyId));
    if (encoded == null || encoded.isEmpty) return null;
    return base64.decode(encoded);
  }

  @override
  Future<bool> hasKey(String keyId) => _storage.containsKey(_formatKey(keyId));

  @override
  Future<void> deleteKey(String keyId) => _storage.delete(_formatKey(keyId));

  @override
  Future<void> clearAllKeys() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_keyPrefix)) {
        await _storage.delete(key);
      }
    }
  }
}
