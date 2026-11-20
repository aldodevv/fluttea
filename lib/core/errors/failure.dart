import 'package:fluttea/core/constants/response/error_codes.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class Failure implements Exception {
  const new({
    required this.code,
    required this.message,
    this.statusCode,
    this.cause,
    this.stackTrace,
  });

  final String code;
  final String message;
  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure(code: $code, message: $message, statusCode: $statusCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.code == code &&
        other.message == message &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => Object.hash(code, message, statusCode);
}

final class NetworkFailure extends Failure {
  const new({
    super.code = ErrorCodes.network,
    super.message = 'Koneksi jaringan terganggu. Silakan periksa koneksi Anda.',
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

final class TimeoutFailure extends Failure {
  const new({
    super.code = ErrorCodes.timeout,
    super.message = 'Waktu permintaan habis. Silakan coba lagi.',
    super.statusCode,
    super.cause,
    super.stackTrace,
  });
}

final class ServerFailure extends Failure {
  const new({
    super.code = ErrorCodes.server,
    super.message = 'Terjadi kendala pada server. Silakan coba beberapa saat lagi.',
    super.statusCode,
    this.payload,
    super.cause,
    super.stackTrace,
  });

  final Map<String, dynamic>? payload;
}

final class AuthFailure extends Failure {
  const new({
    super.code = ErrorCodes.unauthorized,
    super.message = 'Sesi Anda telah berakhir. Silakan masuk kembali.',
    super.statusCode = 401,
    super.cause,
    super.stackTrace,
  });
}

final class ForbiddenFailure extends Failure {
  const new({
    super.code = ErrorCodes.forbidden,
    super.message = 'Anda tidak memiliki hak akses untuk tindakan ini.',
    super.statusCode = 403,
    super.cause,
    super.stackTrace,
  });
}

final class NotFoundFailure extends Failure {
  const new({
    super.code = ErrorCodes.notFound,
    super.message = 'Data yang diminta tidak ditemukan.',
    super.statusCode = 404,
    super.cause,
    super.stackTrace,
  });
}

final class ValidationFailure extends Failure {
  const new({
    super.code = ErrorCodes.validation,
    super.message = 'Data yang dikirimkan tidak valid.',
    super.statusCode = 422,
    this.fieldErrors = const {},
    super.cause,
    super.stackTrace,
  });

  final Map<String, String> fieldErrors;
}

final class StorageFailure extends Failure {
  const new({
    super.code = ErrorCodes.storage,
    super.message = 'Gagal mengakses penyimpanan perangkat.',
    super.cause,
    super.stackTrace,
  });
}

final class SecurityFailure extends Failure {
  const new({
    super.code = ErrorCodes.tampered,
    super.message = 'Integritas keamanan perangkat terganggu.',
    super.cause,
    super.stackTrace,
  });
}

final class PinningFailure extends Failure {
  const new({
    super.code = ErrorCodes.pinning,
    super.message = 'Verifikasi sertifikat keamanan server gagal.',
    super.cause,
    super.stackTrace,
  });
}

final class CancelFailure extends Failure {
  const new({
    super.code = ErrorCodes.cancelled,
    super.message = 'Permintaan dibatalkan.',
    super.cause,
    super.stackTrace,
  });
}

final class ParseFailure extends Failure {
  const new({
    super.code = ErrorCodes.parse,
    super.message = 'Format data respons tidak sesuai.',
    super.cause,
    super.stackTrace,
  });
}

final class UnknownFailure extends Failure {
  const new({
    super.code = ErrorCodes.unknown,
    super.message = 'Terjadi kesalahan yang tidak terduga.',
    super.cause,
    super.stackTrace,
  });
}
