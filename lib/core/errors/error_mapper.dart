import 'dart:async';
import 'dart:io';

import 'package:fluttea/core/errors/failure.dart';

abstract final class ErrorMapper {
  static Failure fromException(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) {
      return error;
    }
    if (error is SocketException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is TimeoutException) {
      return TimeoutFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is FormatException) {
      return ParseFailure(cause: error, stackTrace: stackTrace);
    }
    return UnknownFailure(message: error.toString(), cause: error, stackTrace: stackTrace);
  }
}
