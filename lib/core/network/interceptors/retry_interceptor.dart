import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';

class RetryInterceptor extends AppInterceptor {
  const new({
    required this.dio,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 200),
  });

  final Dio dio;
  final int maxAttempts;
  final Duration initialDelay;

  static final Random _random = Random();
  static const Set<String> _idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  @override
  String get name => 'Retry';

  @override
  int get order => InterceptorOrder.retry;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final method = err.requestOptions.method.toUpperCase();
    final forceRetry = err.requestOptions.extra['retry'] == true;
    final isIdempotent = _idempotentMethods.contains(method) || forceRetry;

    if (!isIdempotent || !_shouldRetry(err)) {
      return handler.next(err);
    }

    final currentAttempt = (err.requestOptions.extra['retryCount'] as int? ?? 0) + 1;
    if (currentAttempt >= maxAttempts) {
      return handler.next(err);
    }

    err.requestOptions.extra['retryCount'] = currentAttempt;

    // Exponential backoff dengan jitter: initialDelay * 2^(attempt-1) + random jitter
    final backoffMultiplier = pow(2, currentAttempt - 1).toDouble();
    final jitterMs = _random.nextInt(100);
    final delayMs = (initialDelay.inMilliseconds * backoffMultiplier).round() + jitterMs;

    await Future<void>.delayed(Duration(milliseconds: delayMs));

    try {
      final response = await dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    } on Object catch (e, stack) {
      handler.next(DioException(requestOptions: err.requestOptions, error: e, stackTrace: stack));
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        return status == 503 || status == 504 || status == 502;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return false;
    }
  }
}
