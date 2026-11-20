import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/network/debug/network_inspector.dart';
import 'package:fluttea/core/network/debug/request_logger.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';

class LogInterceptor extends AppInterceptor {
  const new({this.logger = const RequestLogger(), this.inspector});

  final RequestLogger logger;
  final NetworkInspector? inspector;

  @override
  String get name => 'Log';

  @override
  int get order => InterceptorOrder.logging;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.logRequest(options);
    inspector?.logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    logger.logResponse(response);
    inspector?.logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.logError(err);
    inspector?.logError(err);
    handler.next(err);
  }
}
