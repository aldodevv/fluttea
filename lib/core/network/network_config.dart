import 'package:fluttea/core/network/adapter/proxy_config.dart';
import 'package:fluttea/core/network/base_url/base_url_resolver.dart';
import 'package:fluttea/core/network/base_url/flavor_base_url.dart';
import 'package:fluttea/core/network/debug/network_inspector.dart';
import 'package:fluttea/core/network/debug/request_logger.dart';
import 'package:fluttea/core/network/handlers/error/error_handler.dart';
import 'package:fluttea/core/network/handlers/response/response_pipeline.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';
import 'package:fluttea/core/network/pinning/pin_set.dart';
import 'package:fluttea/core/network/profile/network_profile.dart';

class NetworkConfig {
  const new({
    required this.baseUrlResolver,
    this.interceptors = const [],
    this.pipeline = const ResponsePipeline(),
    this.errorHandler = const ErrorHandler(),
    this.pinSet = const PinSet(failClosed: false),
    this.proxy = const ProxyConfig.none(),
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
    this.pinningEnabled = false,
    this.logger = const RequestLogger(),
    this.inspector,
  });

  /// Membangun konfigurasi jaringan dari NetworkProfile
  factory fromProfile(
    NetworkProfile profile, {
    BaseUrlResolver? resolver,
    List<AppInterceptor> interceptors = const [],
    NetworkInspector? inspector,
  }) {
    return NetworkConfig(
      baseUrlResolver: resolver ?? FlavorBaseUrlResolver(profile.defaultBaseUrl),
      interceptors: interceptors,
      pipeline: profile.pipeline,
      pinSet: profile.pinSet,
      proxy: profile.proxy,
      connectTimeout: profile.connectTimeout,
      receiveTimeout: profile.receiveTimeout,
      pinningEnabled: profile.pinningEnabled,
      logger: RequestLogger(level: profile.logLevel),
      inspector: inspector,
    );
  }

  final BaseUrlResolver baseUrlResolver;
  final List<AppInterceptor> interceptors;
  final ResponsePipeline pipeline;
  final ErrorHandler errorHandler;
  final PinSet pinSet;
  final ProxyConfig proxy;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool pinningEnabled;
  final RequestLogger logger;
  final NetworkInspector? inspector;
}
