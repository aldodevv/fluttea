import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/storage/storage_keys.dart';
import 'package:fluttea/core/network/base_url/chain_base_url.dart';
import 'package:fluttea/core/network/base_url/flavor_base_url.dart';
import 'package:fluttea/core/network/base_url/override_base_url.dart';
import 'package:fluttea/core/network/base_url/remote_config_base_url.dart';
import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedPreferencesAsync extends Fake implements SharedPreferencesAsync {
  final Map<String, String> _storage = {};

  @override
  Future<String?> getString(String key) async => _storage[key];

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }
}

void main() {
  group('BaseUrlResolvers', () {
    late FakeSharedPreferencesAsync fakePrefs;
    late PreferencesStorage preferences;

    setUp(() {
      fakePrefs = FakeSharedPreferencesAsync();
      preferences = PreferencesStorage(preferences: fakePrefs);
    });

    test('FlavorBaseUrlResolver returns configured url', () async {
      const resolver = FlavorBaseUrlResolver('https://api.example.com');
      final uri = await resolver.resolve();
      expect(uri, equals(Uri.parse('https://api.example.com')));
    });

    test('OverrideBaseUrlResolver resolves from storage when allowed', () async {
      await preferences.setString(StorageKeys.baseUrlOverride, 'https://override.example.com');
      final resolver = OverrideBaseUrlResolver(preferences);

      final uri = await resolver.resolve();
      expect(uri, equals(Uri.parse('https://override.example.com')));
    });

    test('OverrideBaseUrlResolver rejects non-https when enforceHttps is true', () async {
      await preferences.setString(StorageKeys.baseUrlOverride, 'http://insecure.example.com');
      final resolver = OverrideBaseUrlResolver(preferences, enforceHttps: true);

      expect(resolver.resolve, throwsA(isA<FormatException>()));
    });

    test('OverrideBaseUrlResolver throws when override is disabled', () async {
      await preferences.setString(StorageKeys.baseUrlOverride, 'https://override.example.com');
      final resolver = OverrideBaseUrlResolver(preferences, allowOverride: false);

      expect(resolver.resolve, throwsA(isA<FormatException>()));
    });

    test('RemoteConfigBaseUrlResolver resolves from callback', () async {
      final resolver = RemoteConfigBaseUrlResolver(() async => 'https://rc.example.com');
      final uri = await resolver.resolve();
      expect(uri, equals(Uri.parse('https://rc.example.com')));
    });

    test('ChainBaseUrlResolver prioritizes options.extra["baseUrl"]', () async {
      const flavor = FlavorBaseUrlResolver('https://flavor.example.com');
      const chain = ChainBaseUrlResolver(resolvers: [flavor]);

      final options = RequestOptions(
        path: '/test',
        extra: {'baseUrl': 'https://dynamic.example.com'},
      );
      final uri = await chain.resolve(options: options);
      expect(uri, equals(Uri.parse('https://dynamic.example.com')));
    });

    test('ChainBaseUrlResolver falls back through resolvers in order', () async {
      // Storage kosong, remote config throws, flavor berhasil
      final overrideResolver = OverrideBaseUrlResolver(preferences);
      final remoteResolver = RemoteConfigBaseUrlResolver(() async => null);
      const flavorResolver = FlavorBaseUrlResolver('https://fallback.example.com');

      final chain = ChainBaseUrlResolver(
        resolvers: [overrideResolver, remoteResolver, flavorResolver],
      );

      final uri = await chain.resolve();
      expect(uri, equals(Uri.parse('https://fallback.example.com')));
    });
  });
}
