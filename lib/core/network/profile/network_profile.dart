import 'package:fluttea/core/constants/api/api_hosts.dart';
import 'package:fluttea/core/network/adapter/proxy_config.dart';
import 'package:fluttea/core/network/debug/request_logger.dart';
import 'package:fluttea/core/network/handlers/response/envelope_handler.dart';
import 'package:fluttea/core/network/handlers/response/plain_json_handler.dart';
import 'package:fluttea/core/network/handlers/response/response_pipeline.dart';
import 'package:fluttea/core/network/handlers/response/status_code_handler.dart';
import 'package:fluttea/core/network/pinning/pin_set.dart';
import 'package:fluttea/core/network/pinning/pin_strategy.dart';
import 'package:fluttea/core/network/profile/response_schema.dart';

class NetworkProfile {
  const new({
    required this.name,
    required this.defaultBaseUrl,
    this.pipeline = const ResponsePipeline(),
    this.pinSet = const PinSet(failClosed: false),
    this.proxy = const ProxyConfig.none(),
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.logLevel = NetworkLogLevel.basic,
    this.pinningEnabled = false,
  });

  /// Profil untuk integrasi mock server (https://www.mock-server.com/)
  /// Mendukung simulasi proxy, cert pinning, dan skema respons adaptif.
  factory mockServer({
    String baseUrl = ApiHosts.mockServer,
    ProxyConfig proxy = const ProxyConfig.none(),
    PinSet? pinSet,
    bool pinningEnabled = false,
    NetworkLogLevel logLevel = NetworkLogLevel.basic,
  }) {
    return NetworkProfile(
      name: 'MockServer',
      defaultBaseUrl: baseUrl,
      proxy: proxy,
      pinSet:
          pinSet ??
          const PinSet(rules: {'www.mock-server.com': PinStrategy.off()}, failClosed: false),
      pinningEnabled: pinningEnabled,
      logLevel: logLevel,
      pipeline: const ResponsePipeline(
        handlers: [
          StatusCodeHandler(),
          EnvelopeHandler(spec: EnvelopeSpec.mockServer),
          EnvelopeHandler(),
          PlainJsonHandler(),
        ],
      ),
    );
  }

  /// Profil standar aplikasi dengan skema Envelope {code, message, data}
  factory standard({
    required String defaultBaseUrl,
    PinSet? pinSet,
    ProxyConfig proxy = const ProxyConfig.none(),
    bool pinningEnabled = true,
    NetworkLogLevel logLevel = NetworkLogLevel.basic,
  }) {
    return NetworkProfile(
      name: 'Standard',
      defaultBaseUrl: defaultBaseUrl,
      proxy: proxy,
      pinSet: pinSet ?? const PinSet(),
      pinningEnabled: pinningEnabled,
      logLevel: logLevel,
    );
  }

  /// Profil Plain REST tanpa envelope (2xx = direct body)
  factory plainRest({
    required String defaultBaseUrl,
    PinSet? pinSet,
    ProxyConfig proxy = const ProxyConfig.none(),
    bool pinningEnabled = false,
    NetworkLogLevel logLevel = NetworkLogLevel.basic,
  }) {
    return NetworkProfile(
      name: 'PlainRest',
      defaultBaseUrl: defaultBaseUrl,
      proxy: proxy,
      pinSet: pinSet ?? const PinSet(failClosed: false),
      pinningEnabled: pinningEnabled,
      logLevel: logLevel,
      pipeline: const ResponsePipeline(handlers: [StatusCodeHandler(), PlainJsonHandler()]),
    );
  }

  final String name;
  final String defaultBaseUrl;
  final ResponsePipeline pipeline;
  final PinSet pinSet;
  final ProxyConfig proxy;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final NetworkLogLevel logLevel;
  final bool pinningEnabled;
}
