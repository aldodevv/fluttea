import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';

class RequestIdInterceptor extends AppInterceptor {
  const new({this.headerName = 'X-Request-Id'});

  final String headerName;

  static final Random _random = Random.secure();

  @override
  String get name => 'RequestId';

  @override
  int get order => InterceptorOrder.requestId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final existingId = options.headers[headerName];
    final id = existingId is String && existingId.isNotEmpty ? existingId : _generateId();

    options.headers[headerName] = id;
    options.extra['requestId'] = id;
    options.extra['requestStart'] = DateTime.now().millisecondsSinceEpoch;

    handler.next(options);
  }

  static String _generateId() {
    final bytes = List<int>.generate(8, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
