final class _CacheEntry<T> {
  const new(this.value, this.expiry);

  final T value;
  final DateTime? expiry;

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}

class MemoryCache {
  final Map<String, _CacheEntry<dynamic>> _store = {};

  void put<T>(String key, T value, {Duration? ttl}) {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _store[key] = _CacheEntry<T>(value, expiry);
  }

  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }

    if (entry.value is T) {
      return entry.value as T;
    }
    return null;
  }

  bool has(String key) {
    return get<dynamic>(key) != null;
  }

  void remove(String key) {
    _store.remove(key);
  }

  void clear() {
    _store.clear();
  }

  int get size => _store.length;
}
