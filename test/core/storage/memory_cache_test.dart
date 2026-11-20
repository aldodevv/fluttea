import 'package:fluttea/core/storage/cache/memory_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryCache', () {
    late MemoryCache cache;

    setUp(() {
      cache = MemoryCache();
    });

    test('put and get value without ttl', () {
      cache.put('user_id', 12345);
      expect(cache.has('user_id'), isTrue);
      expect(cache.get<int>('user_id'), equals(12345));
    });

    test('returns null for non-existing key', () {
      expect(cache.get<String>('unknown'), isNull);
      expect(cache.has('unknown'), isFalse);
    });

    test('returns null for mismatched type', () {
      cache.put('score', 'high');
      expect(cache.get<int>('score'), isNull);
    });

    test('handles expired ttl', () async {
      cache.put('temp_key', 'temp_val', ttl: const Duration(milliseconds: 10));
      expect(cache.get<String>('temp_key'), equals('temp_val'));

      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(cache.get<String>('temp_key'), isNull);
      expect(cache.has('temp_key'), isFalse);
    });

    test('remove deletes item from cache', () {
      cache.put('key1', 'val1');
      expect(cache.has('key1'), isTrue);

      cache.remove('key1');
      expect(cache.has('key1'), isFalse);
    });

    test('clear removes all items', () {
      cache
        ..put('k1', 'v1')
        ..put('k2', 'v2');
      expect(cache.size, equals(2));

      cache.clear();
      expect(cache.size, equals(0));
      expect(cache.has('k1'), isFalse);
      expect(cache.has('k2'), isFalse);
    });
  });
}
