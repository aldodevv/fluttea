import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/handlers/response/envelope_handler.dart';
import 'package:fluttea/core/network/handlers/response/plain_json_handler.dart';
import 'package:fluttea/core/network/handlers/response/response_handler.dart';
import 'package:fluttea/core/network/handlers/response/status_code_handler.dart';

class ResponsePipeline {
  const new({this.handlers = defaultHandlers});

  final List<ResponseHandler> handlers;

  static const List<ResponseHandler> defaultHandlers = [
    StatusCodeHandler(),
    EnvelopeHandler(),
    PlainJsonHandler(),
  ];

  Result<T> process<T>(Response<dynamic> response, T Function(dynamic json)? fromJson) {
    for (final handler in handlers) {
      if (handler.canHandle(response)) {
        return handler.handle<T>(response, fromJson);
      }
    }

    return Result<T>.err(
      const ParseFailure(
        message: 'Tidak ada response handler yang cocok untuk memproses respons ini.',
      ),
    );
  }
}
