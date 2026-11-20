import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluttea/core/network/adapter/http_client_factory.dart';
import 'package:fluttea/core/network/adapter/proxy_config.dart';

class AdapterFactory {
  const new();

  static HttpClientAdapter create({
    SecurityContext? securityContext,
    ProxyConfig proxy = const ProxyConfig.none(),
    Duration connectionTimeout = const Duration(seconds: 15),
    Duration idleTimeout = const Duration(seconds: 15),
    BadCertificateCallback? badCertificateCallback,
    ValidateCertificate? validateCertificate,
  }) {
    return IOHttpClientAdapter(
      createHttpClient: () => HttpClientFactory.create(
        context: securityContext,
        proxy: proxy,
        connectionTimeout: connectionTimeout,
        idleTimeout: idleTimeout,
        badCertificateCallback: badCertificateCallback,
      ),
      validateCertificate: validateCertificate,
    );
  }
}
