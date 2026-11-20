import 'dart:io';

import 'package:fluttea/core/network/adapter/proxy_config.dart';

class HttpClientFactory {
  const new();

  static HttpClient create({
    SecurityContext? context,
    ProxyConfig proxy = const ProxyConfig.none(),
    Duration connectionTimeout = const Duration(seconds: 15),
    Duration idleTimeout = const Duration(seconds: 15),
    BadCertificateCallback? badCertificateCallback,
  }) {
    final client = HttpClient(context: context)
      ..connectionTimeout = connectionTimeout
      ..idleTimeout = idleTimeout;

    if (badCertificateCallback != null) {
      client.badCertificateCallback = badCertificateCallback;
    }

    client.findProxy = proxy.findProxy;
    proxy.applyCredentials(client);

    return client;
  }
}
