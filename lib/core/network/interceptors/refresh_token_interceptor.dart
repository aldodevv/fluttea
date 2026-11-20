import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/api_headers.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';
import 'package:flutter/foundation.dart';

class RefreshTokenInterceptor extends AppInterceptor {
  new({
    required this.dio,
    required this.onRefreshToken,
    required this.getNewToken,
    this.onSessionExpired,
  });

  final Dio dio;
  final Future<bool> Function() onRefreshToken;
  final Future<String?> Function() getNewToken;
  final VoidCallback? onSessionExpired;

  Completer<bool>? _refreshCompleter;

  @override
  String get name => 'RefreshToken';

  @override
  int get order => InterceptorOrder.refreshToken;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final isUnauthorized = response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final isRefreshEndpoint = err.requestOptions.extra['isRefresh'] == true;

    if (!isUnauthorized || alreadyRetried || isRefreshEndpoint) {
      return handler.next(err);
    }

    try {
      final success = await _executeRefreshSingleFlight();
      if (!success) {
        onSessionExpired?.call();
        return handler.next(err);
      }

      // Ambil token baru dan ulang request
      final newToken = await getNewToken();
      final options = err.requestOptions;
      options.extra['retried'] = true;
      if (newToken != null && newToken.isNotEmpty) {
        options.headers[ApiHeaders.authorization] = 'Bearer $newToken';
      }

      final retriedResponse = await dio.fetch<dynamic>(options);
      return handler.resolve(retriedResponse);
    } on Object catch (e, stack) {
      onSessionExpired?.call();
      return handler.next(
        DioException(requestOptions: err.requestOptions, error: e, stackTrace: stack),
      );
    }
  }

  Future<bool> _executeRefreshSingleFlight() async {
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final result = await onRefreshToken();
      completer.complete(result);
      return result;
    } on Object {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
