import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/result.dart';

abstract interface class ResponseHandler {
  bool canHandle(Response<dynamic> response);

  Result<T> handle<T>(Response<dynamic> response, T Function(dynamic json)? fromJson);
}
