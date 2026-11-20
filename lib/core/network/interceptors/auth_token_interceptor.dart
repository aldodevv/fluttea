import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/api_headers.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';

class AuthTokenInterceptor extends AppInterceptor {
  const new({required this.getToken});

  final Future<String?> Function() getToken;

  @override
  String get name => 'AuthToken';

  @override
  int get order => InterceptorOrder.authToken;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final noAuth = options.extra['noAuth'] == true;
    if (noAuth) {
      return handler.next(options);
    }

    try {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiHeaders.authorization] = 'Bearer $token';
      }
    } on Object {
      // Abaikan jika pembacaan token gagal, biarkan request berlanjut
    }

    handler.next(options);
  }
}
