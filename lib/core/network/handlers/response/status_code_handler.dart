import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/handlers/response/response_handler.dart';

class StatusCodeHandler implements ResponseHandler {
  const new();

  @override
  bool canHandle(Response<dynamic> response) {
    return response.statusCode == 204;
  }

  @override
  Result<T> handle<T>(Response<dynamic> response, T Function(dynamic json)? fromJson) {
    return Result<T>.ok(null as T);
  }
}
