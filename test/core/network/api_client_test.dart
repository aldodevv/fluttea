import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/network/api_client.dart';
import 'package:fluttea/core/network/base_url/flavor_base_url.dart';
import 'package:fluttea/core/network/network_config.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeHttpClientAdapter implements HttpClientAdapter {
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
  group('ApiClient', () {
    late Dio dio;
    late NetworkConfig config;
    late ApiClient client;

    setUp(() {
      config = const NetworkConfig(
        baseUrlResolver: FlavorBaseUrlResolver('https://api.example.com'),
      );
      dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
      client = ApiClient(config: config, dio: dio);
    });

    test('get returns Ok when response is 200 JSON', () async {
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        final bodyBytes = utf8.encode(json.encode({'id': '123', 'name': 'Item A'}));
        return ResponseBody.fromBytes(
          bodyBytes,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await client.request<Map<String, dynamic>>(HttpMethod.get, '/items/1');
      expect(result.isOk, isTrue);
      expect(result.dataOrNull?['name'], equals('Item A'));
    });

    test('post returns Ok with parsed object fromJson', () async {
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        final bodyBytes = utf8.encode(json.encode({'status': 'created', 'id': '99'}));
        return ResponseBody.fromBytes(
          bodyBytes,
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await client.request<String>(
        HttpMethod.post,
        '/items',
        data: {'name': 'New Item'},
        fromJson: (json) => (json as Map<String, dynamic>)['id'] as String,
      );

      expect(result.isOk, isTrue);
      expect(result.dataOrNull, equals('99'));
    });

    test('returns Err(Failure) on 404 without throwing exception', () async {
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        final bodyBytes = utf8.encode(json.encode({'message': 'Resource not found'}));
        return ResponseBody.fromBytes(
          bodyBytes,
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await client.request<dynamic>(HttpMethod.get, '/not-found');
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
      expect(result.failureOrNull?.statusCode, equals(404));
    });

    test('returns Err(TimeoutFailure) on connection timeout without throwing', () async {
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        throw DioException(requestOptions: options, type: DioExceptionType.connectionTimeout);
      });

      final result = await client.request<dynamic>(HttpMethod.get, '/timeout');
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<TimeoutFailure>());
    });

    test('delete returns Ok on 204 No Content', () async {
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return ResponseBody.fromBytes([], 204);
      });

      final result = await client.request<void>(HttpMethod.delete, '/items/1');
      expect(result.isOk, isTrue);
    });
  });
}
