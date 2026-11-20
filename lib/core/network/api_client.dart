import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/handlers/error/error_handler.dart';
import 'package:fluttea/core/network/handlers/response/response_pipeline.dart';
import 'package:fluttea/core/network/network_builder.dart';
import 'package:fluttea/core/network/network_config.dart';

enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  new(this.value);
  final String value;
}

class ApiClient {
  new({required NetworkConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? NetworkBuilder.build(config),
      _pipeline = config.pipeline,
      _errorHandler = config.errorHandler;

  final NetworkConfig _config;
  final Dio _dio;
  final ResponsePipeline _pipeline;
  final ErrorHandler _errorHandler;

  Dio get rawDio => _dio;
  NetworkConfig get config => _config;

  Future<Result<T>> request<T>(
    HttpMethod method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? fromJson,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method.value, headers: headers, extra: extra),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return _pipeline.process<T>(response, fromJson);
    } on DioException catch (e) {
      return Result<T>.err(_errorHandler.handle(e));
    } on Object catch (e, stack) {
      return Result<T>.err(
        UnknownFailure(
          message: 'Terjadi kegagalan komunikasi jaringan.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<String>> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: Options(headers: headers, extra: extra),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return Result<String>.ok(savePath);
      }
      return Result<String>.err(
        ServerFailure(
          statusCode: response.statusCode,
          message: 'Download gagal dengan status ${response.statusCode}.',
        ),
      );
    } on DioException catch (e) {
      return Result<String>.err(_errorHandler.handle(e));
    } on Object catch (e, stack) {
      return Result<String>.err(
        UnknownFailure(
          message: 'Terjadi kendala saat mengunduh file.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
