import 'package:fluttea/core/constants/response/error_codes.dart';
import 'package:fluttea/core/errors/failure.dart';

abstract final class FailureMapper {
  static Failure map({int? statusCode, dynamic data, Object? cause, StackTrace? stackTrace}) {
    var message = 'Terjadi kesalahan pada layanan.';
    var code = ErrorCodes.unknown;
    Map<String, dynamic>? payload;
    var fieldErrors = <String, String>{};

    if (data is Map) {
      payload = data.cast<String, dynamic>();
      if (data['message'] != null) {
        message = data['message'].toString();
      }
      if (data['code'] != null) {
        code = data['code'].toString();
      }
      if (data['errors'] is Map) {
        fieldErrors = (data['errors'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(
          code: code != ErrorCodes.unknown ? code : ErrorCodes.validation,
          message: message,
          statusCode: statusCode,
          fieldErrors: fieldErrors,
          cause: cause,
          stackTrace: stackTrace,
        );
      case 401:
        return AuthFailure(
          code: code != ErrorCodes.unknown ? code : ErrorCodes.unauthorized,
          message: message,
          statusCode: statusCode,
          cause: cause,
          stackTrace: stackTrace,
        );
      case 403:
        return ForbiddenFailure(
          code: code != ErrorCodes.unknown ? code : ErrorCodes.forbidden,
          message: message,
          statusCode: statusCode,
          cause: cause,
          stackTrace: stackTrace,
        );
      case 404:
        return NotFoundFailure(
          code: code != ErrorCodes.unknown ? code : ErrorCodes.notFound,
          message: message,
          statusCode: statusCode,
          cause: cause,
          stackTrace: stackTrace,
        );
      case 422:
        return ValidationFailure(
          code: code != ErrorCodes.unknown ? code : ErrorCodes.validation,
          message: message,
          statusCode: statusCode,
          fieldErrors: fieldErrors,
          cause: cause,
          stackTrace: stackTrace,
        );
      case final c? when c >= 500 && c < 600:
        return ServerFailure(
          code: code != ErrorCodes.unknown ? code : ErrorCodes.server,
          message: message,
          statusCode: statusCode,
          payload: payload,
          cause: cause,
          stackTrace: stackTrace,
        );
      default:
        return ServerFailure(
          code: code,
          message: message,
          statusCode: statusCode,
          payload: payload,
          cause: cause,
          stackTrace: stackTrace,
        );
    }
  }
}
