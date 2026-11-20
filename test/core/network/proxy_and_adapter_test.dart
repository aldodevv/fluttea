import 'package:fluttea/core/network/adapter/adapter_factory.dart';
import 'package:fluttea/core/network/adapter/http_client_factory.dart';
import 'package:fluttea/core/network/adapter/proxy_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProxyConfig & HttpClientFactory', () {
    test('ProxyConfig.none directs traffic directly', () {
      const proxy = ProxyConfig.none();
      expect(proxy.isNone, isTrue);
      expect(proxy.isManual, isFalse);
      expect(proxy.findProxy(Uri.parse('https://example.com')), equals('DIRECT'));
    });

    test('ProxyConfig.manual configures host and port correctly', () {
      const proxy = ProxyConfig.manual(host: '127.0.0.1', port: 8080);
      expect(proxy.isManual, isTrue);
      expect(proxy.proxyAddress, equals('127.0.0.1:8080'));
      expect(proxy.findProxy(Uri.parse('https://example.com')), equals('PROXY 127.0.0.1:8080'));
    });

    test('HttpClientFactory creates HttpClient with configured timeouts', () {
      final client = HttpClientFactory.create(
        proxy: const ProxyConfig.manual(host: 'localhost', port: 8888),
        connectionTimeout: const Duration(seconds: 10),
        idleTimeout: const Duration(seconds: 20),
      );

      expect(client.connectionTimeout, equals(const Duration(seconds: 10)));
      expect(client.idleTimeout, equals(const Duration(seconds: 20)));
      client.close();
    });

    test('AdapterFactory creates HttpClientAdapter', () {
      final adapter = AdapterFactory.create();
      expect(adapter, isNotNull);
    });
  });
}
