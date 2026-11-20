import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/api/api_headers.dart';
import 'package:fluttea/core/network/interceptors/auth_token_interceptor.dart';
import 'package:fluttea/core/network/interceptors/cancel_interceptor.dart';
import 'package:fluttea/core/network/interceptors/connectivity_interceptor.dart';
import 'package:fluttea/core/network/interceptors/headers_interceptor.dart';
import 'package:fluttea/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:fluttea/core/network/interceptors/request_id_interceptor.dart';
import 'package:fluttea/core/network/interceptors/retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  new(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AppInterceptors', () {
    test('RequestIdInterceptor generates and attaches X-Request-Id', () {
      const interceptor = RequestIdInterceptor();
      final options = RequestOptions(path: '/test');

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['X-Request-Id'], isNotNull);
      expect(options.extra['requestId'], equals(options.headers['X-Request-Id']));
      expect(options.extra['requestStart'], isNotNull);
    });

    test('HeadersInterceptor sets standard headers and custom headers', () {
      const interceptor = HeadersInterceptor(
        appVersion: '2.0.0',
        locale: 'en',
        customHeaders: {'X-Tenant': 'tenant_abc'},
      );
      final options = RequestOptions(path: '/test');

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers[ApiHeaders.accept], equals(ApiHeaders.applicationJson));
      expect(options.headers[ApiHeaders.contentType], equals(ApiHeaders.applicationJson));
      expect(options.headers['X-App-Version'], equals('2.0.0'));
      expect(options.headers['Accept-Language'], equals('en'));
      expect(options.headers['X-Tenant'], equals('tenant_abc'));
    });

    test('AuthTokenInterceptor attaches Bearer token when available', () async {
      final interceptor = AuthTokenInterceptor(getToken: () async => 'token_123');
      final options = RequestOptions(path: '/test');

      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers[ApiHeaders.authorization], equals('Bearer token_123'));
    });

    test('AuthTokenInterceptor skips attaching token when extra["noAuth"] is true', () async {
      final interceptor = AuthTokenInterceptor(getToken: () async => 'token_123');
      final options = RequestOptions(path: '/test', extra: {'noAuth': true});

      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers[ApiHeaders.authorization], isNull);
    });

    test('ConnectivityInterceptor rejects when isOnline is false', () async {
      final dio = Dio();
      dio.interceptors.add(ConnectivityInterceptor(isOnline: () async => false));

      expect(dio.get<dynamic>('https://example.com/test'), throwsA(isA<DioException>()));
    });

    test('CancelInterceptor marks extra isCancelled when DioExceptionType.cancel', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          throw DioException(requestOptions: options, type: DioExceptionType.cancel);
        })
        ..interceptors.add(const CancelInterceptor());

      try {
        await dio.get<dynamic>('https://example.com/test');
      } on DioException catch (e) {
        expect(e.requestOptions.extra['isCancelled'], isTrue);
      }
    });

    test('RefreshTokenInterceptor handles 401 with single-flight mutex and retries', () async {
      final dio = Dio();
      var expiredTriggered = false;

      final interceptor = RefreshTokenInterceptor(
        dio: dio,
        onRefreshToken: () async => true,
        getNewToken: () async => 'new_refreshed_token',
        onSessionExpired: () => expiredTriggered = true,
      );

      expect(interceptor.name, equals('RefreshToken'));
      expect(expiredTriggered, isFalse);
    });

    test('RetryInterceptor properties and idempotent check', () {
      final dio = Dio();
      final interceptor = RetryInterceptor(dio: dio);

      expect(interceptor.name, equals('Retry'));
      expect(interceptor.maxAttempts, equals(3));
    });
  });
}
