import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';

class ConnectivityInterceptor extends AppInterceptor {
  const new({required this.isOnline});

  final Future<bool> Function() isOnline;

  @override
  String get name => 'Connectivity';

  @override
  int get order => InterceptorOrder.connectivity;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final online = await isOnline();
    if (!online) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        ),
      );
    }

    handler.next(options);
  }
}
