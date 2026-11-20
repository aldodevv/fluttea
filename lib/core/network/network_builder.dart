import 'package:dio/dio.dart';
import 'package:fluttea/core/network/base_url/base_url_resolver.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';
import 'package:fluttea/core/network/network_config.dart';
import 'package:fluttea/core/network/pinning/pinned_http_client_factory.dart';

class NetworkBuilder {
  const new();

  static Dio build(NetworkConfig config) {
    final dio =
        Dio(
            BaseOptions(
              connectTimeout: config.connectTimeout,
              receiveTimeout: config.receiveTimeout,
              sendTimeout: config.sendTimeout,
            ),
          )
          ..httpClientAdapter = PinnedHttpClientFactory.createAdapter(
            pinSet: config.pinSet,
            pinningEnabled: config.pinningEnabled,
            proxy: config.proxy,
            connectionTimeout: config.connectTimeout,
            idleTimeout: config.receiveTimeout,
          );

    final enabledInterceptors = config.interceptors.where((i) => i.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    dio.interceptors
      ..add(_DynamicBaseUrlInterceptor(config.baseUrlResolver))
      ..addAll(enabledInterceptors);

    return dio;
  }
}

class _DynamicBaseUrlInterceptor extends AppInterceptor {
  const new(this.resolver);

  final BaseUrlResolver resolver;

  @override
  String get name => 'DynamicBaseUrl';

  @override
  int get order => 0;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (options.baseUrl.isEmpty) {
        final uri = await resolver.resolve(options: options);
        options.baseUrl = uri.toString();
      }
      handler.next(options);
    } on Object catch (e, stack) {
      handler.reject(DioException(requestOptions: options, error: e, stackTrace: stack));
    }
  }
}
