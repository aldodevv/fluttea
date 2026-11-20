import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  const new({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(storageNamespace: 'fluttea_secure_vault'),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          );

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<bool> containsKey(String key) => _storage.containsKey(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<Map<String, String>> readAll() => _storage.readAll();
}
