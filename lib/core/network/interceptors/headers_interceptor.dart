import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/api_headers.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';
import 'package:fluttea/core/utils/platform/platform_info.dart';

class HeadersInterceptor extends AppInterceptor {
  const new({this.appVersion = AppInfo.version, this.locale = 'id', this.customHeaders = const {}});

  final String appVersion;
  final String locale;
  final Map<String, String> customHeaders;

  @override
  String get name => 'Headers';

  @override
  int get order => InterceptorOrder.headers;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(ApiHeaders.accept, () => ApiHeaders.applicationJson);
    options.headers.putIfAbsent(ApiHeaders.contentType, () => ApiHeaders.applicationJson);
    options.headers.putIfAbsent('X-App-Version', () => appVersion);
    options.headers.putIfAbsent('X-Platform', () => PlatformInfo.name);
    options.headers.putIfAbsent('Accept-Language', () => locale);

    for (final entry in customHeaders.entries) {
      options.headers.putIfAbsent(entry.key, () => entry.value);
    }

    handler.next(options);
  }
}
