import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/network/handlers/error/failure_mapper.dart';

class ErrorHandler {
  const new();

  Failure handle(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutFailure(
          message: 'Waktu tunggu permintaan habis. Silakan coba kembali.',
          cause: exception,
          stackTrace: exception.stackTrace,
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'Koneksi jaringan gagal. Periksa koneksi internet Anda.',
          cause: exception,
          stackTrace: exception.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return PinningFailure(
          message: 'Sertifikat keamanan server tidak valid atau tidak cocok.',
          cause: exception,
          stackTrace: exception.stackTrace,
        );

      case DioExceptionType.cancel:
        return CancelFailure(cause: exception, stackTrace: exception.stackTrace);

      case DioExceptionType.badResponse:
        final response = exception.response;
        return FailureMapper.map(
          statusCode: response?.statusCode,
          data: response?.data,
          cause: exception,
          stackTrace: exception.stackTrace,
        );

      case DioExceptionType.unknown:
        if (exception.error is Failure) {
          return exception.error! as Failure;
        }
        return UnknownFailure(
          message: exception.message ?? 'Terjadi kesalahan tidak terduga.',
          cause: exception,
          stackTrace: exception.stackTrace,
        );
    }
  }
}
