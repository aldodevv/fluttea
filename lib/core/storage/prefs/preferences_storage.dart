import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  new({SharedPreferencesAsync? preferences}) : _customPrefs = preferences;

  final SharedPreferencesAsync? _customPrefs;

  SharedPreferencesAsync? get _prefs {
    if (_customPrefs != null) return _customPrefs;
    try {
      return SharedPreferencesAsync();
    } on Object {
      return null;
    }
  }

  Future<String?> getString(String key) async {
    final prefs = _prefs;
    if (prefs == null) return null;
    return await prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = _prefs;
    if (prefs == null) return null;
    return await prefs.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setInt(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = _prefs;
    if (prefs == null) return null;
    return await prefs.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(key, value);
  }

  Future<double?> getDouble(String key) async {
    final prefs = _prefs;
    if (prefs == null) return null;
    return await prefs.getDouble(key);
  }

  Future<void> setDouble(String key, double value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setDouble(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    final prefs = _prefs;
    if (prefs == null) return null;
    return await prefs.getStringList(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setStringList(key, value);
  }

  Future<Set<String>> getKeys() async {
    final prefs = _prefs;
    if (prefs == null) return const <String>{};
    return await prefs.getKeys();
  }

  Future<void> remove(String key) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.clear();
  }
}
