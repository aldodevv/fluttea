import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/handlers/response/response_handler.dart';
import 'package:fluttea/core/network/profile/response_schema.dart';

class EnvelopeHandler implements ResponseHandler {
  const new({this.spec = EnvelopeSpec.standard});

  final EnvelopeSpec spec;

  @override
  bool canHandle(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map) return false;
    return data.containsKey(spec.dataKey) || data.containsKey(spec.codeKey);
  }

  @override
  Result<T> handle<T>(Response<dynamic> response, T Function(dynamic json)? fromJson) {
    final body = response.data;
    if (body is! Map) {
      return Result<T>.err(
        const ParseFailure(message: 'Format data respons tidak berupa JSON object.'),
      );
    }

    final code = body[spec.codeKey];
    final message = body[spec.messageKey]?.toString() ?? 'Permintaan berhasil.';
    final rawData = body[spec.dataKey];

    // Cek apakah kode respons menyatakan sukses
    final isSuccess = code == null || spec.isSuccess(code);
    if (!isSuccess) {
      return Result<T>.err(
        ServerFailure(
          code: code.toString(),
          message: message,
          statusCode: response.statusCode,
          payload: body.cast<String, dynamic>(),
        ),
      );
    }

    try {
      if (fromJson != null) {
        return Result<T>.ok(fromJson(rawData));
      }
      return Result<T>.ok(rawData as T);
    } on Object catch (e, stack) {
      return Result<T>.err(
        ParseFailure(message: 'Gagal mengurai data respons: $e', cause: e, stackTrace: stack),
      );
    }
  }
}
