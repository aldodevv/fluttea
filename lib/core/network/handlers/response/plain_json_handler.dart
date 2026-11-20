import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/handlers/response/response_handler.dart';

class PlainJsonHandler implements ResponseHandler {
  const new();

  @override
  bool canHandle(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    return status >= 200 && status < 300;
  }

  @override
  Result<T> handle<T>(Response<dynamic> response, T Function(dynamic json)? fromJson) {
    final rawData = response.data;

    try {
      if (fromJson != null) {
        return Result<T>.ok(fromJson(rawData));
      }
      return Result<T>.ok(rawData as T);
    } on Object catch (e, stack) {
      return Result<T>.err(
        ParseFailure(message: 'Gagal mengurai respons: $e', cause: e, stackTrace: stack),
      );
    }
  }
}
