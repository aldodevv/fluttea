import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/network/handlers/response/envelope_handler.dart';
import 'package:fluttea/core/network/handlers/response/plain_json_handler.dart';
import 'package:fluttea/core/network/handlers/response/response_pipeline.dart';
import 'package:fluttea/core/network/handlers/response/status_code_handler.dart';
import 'package:fluttea/core/network/profile/response_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Response Pipeline & Handlers', () {
    final requestOptions = RequestOptions(path: '/test');

    test('StatusCodeHandler handles 204 No Content', () {
      const handler = StatusCodeHandler();
      final response = Response<dynamic>(requestOptions: requestOptions, statusCode: 204);

      expect(handler.canHandle(response), isTrue);
      final result = handler.handle<void>(response, null);
      expect(result.isOk, isTrue);
    });

    test('EnvelopeHandler parses standard envelope format', () {
      const handler = EnvelopeHandler();
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {
          'code': 200,
          'message': 'OK',
          'data': {'userId': 'user_1', 'name': 'John'},
        },
      );

      expect(handler.canHandle(response), isTrue);
      final result = handler.handle<Map<String, dynamic>>(
        response,
        (json) => json as Map<String, dynamic>,
      );

      expect(result.isOk, isTrue);
      expect(result.dataOrNull?['name'], equals('John'));
    });

    test('EnvelopeHandler returns ServerFailure when code is not success', () {
      const handler = EnvelopeHandler();
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 400,
        data: {'code': 'ERR_INVALID_INPUT', 'message': 'Data tidak valid.', 'data': null},
      );

      final result = handler.handle<dynamic>(response, null);
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, equals('Data tidak valid.'));
    });

    test('EnvelopeHandler works with EnvelopeSpec.mockServer', () {
      const handler = EnvelopeHandler(spec: EnvelopeSpec.mockServer);
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {
          'statusCode': 200,
          'message': 'Mock server success',
          'data': {'mockKey': 'mockValue'},
        },
      );

      expect(handler.canHandle(response), isTrue);
      final result = handler.handle<Map<String, dynamic>>(
        response,
        (json) => json as Map<String, dynamic>,
      );

      expect(result.isOk, isTrue);
      expect(result.dataOrNull?['mockKey'], equals('mockValue'));
    });

    test('PlainJsonHandler handles raw list/map without envelope', () {
      const handler = PlainJsonHandler();
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: [
          {'id': 1, 'name': 'Product 1'},
          {'id': 2, 'name': 'Product 2'},
        ],
      );

      expect(handler.canHandle(response), isTrue);
      final result = handler.handle<List<dynamic>>(response, null);
      expect(result.isOk, isTrue);
      expect(result.dataOrNull?.length, equals(2));
    });

    test('ResponsePipeline selects first matching handler in order', () {
      const pipeline = ResponsePipeline();
      final response = Response<dynamic>(requestOptions: requestOptions, statusCode: 204);

      final result = pipeline.process<void>(response, null);
      expect(result.isOk, isTrue);
    });
  });
}
