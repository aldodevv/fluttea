import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluttea/core/network/adapter/http_client_factory.dart';
import 'package:fluttea/core/network/adapter/proxy_config.dart';
import 'package:fluttea/core/network/pinning/pin_set.dart';

class PinnedHttpClientFactory {
  const new();

  static HttpClientAdapter createAdapter({
    required PinSet pinSet,
    bool pinningEnabled = true,
    ProxyConfig proxy = const ProxyConfig.none(),
    Duration connectionTimeout = const Duration(seconds: 15),
    Duration idleTimeout = const Duration(seconds: 15),
  }) {
    SecurityContext? context;

    if (pinningEnabled) {
      // Per research/pinning.md:
      // Matikan default trusted roots agar badCertificateCallback selalu dipanggil
      // saat handshake TLS sebelum request dikirimkan ke server.
      context = SecurityContext();

      // Jika ada CaPin, daftarkan byte sertifikat CA ke SecurityContext
      for (final strategy in pinSet.rules.values) {
        strategy.trustedCaBytes.forEach(context.setTrustedCertificatesBytes);
      }
    }

    return IOHttpClientAdapter(
      createHttpClient: () => HttpClientFactory.create(
        context: context,
        proxy: proxy,
        connectionTimeout: connectionTimeout,
        idleTimeout: idleTimeout,
        badCertificateCallback: pinningEnabled
            ? (cert, host, port) => pinSet.matches(cert, host, port)
            : null,
      ),
      validateCertificate: pinningEnabled
          ? (cert, host, port) => pinSet.matches(cert, host, port)
          : null,
    );
  }
}
