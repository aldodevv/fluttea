import 'package:dio/dio.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';

class CancelInterceptor extends AppInterceptor {
  const new();

  @override
  String get name => 'Cancel';

  @override
  int get order => 5;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.cancel) {
      err.requestOptions.extra['isCancelled'] = true;
    }
    handler.next(err);
  }
}
