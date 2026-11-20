import 'package:dio/dio.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/network/handlers/error/error_handler.dart';
import 'package:fluttea/core/network/handlers/error/failure_mapper.dart';
import 'package:fluttea/core/network/handlers/session/force_logout_workflow.dart';
import 'package:fluttea/core/network/handlers/session/refresh_session_workflow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Error Handlers & Session Workflows', () {
    test('FailureMapper maps various HTTP status codes to concrete Failures', () {
      final f400 = FailureMapper.map(statusCode: 400, data: {'message': 'Bad Request'});
      expect(f400, isA<ValidationFailure>());

      final f401 = FailureMapper.map(statusCode: 401, data: {'message': 'Unauthorized'});
      expect(f401, isA<AuthFailure>());

      final f403 = FailureMapper.map(statusCode: 403, data: {'message': 'Forbidden'});
      expect(f403, isA<ForbiddenFailure>());

      final f404 = FailureMapper.map(statusCode: 404, data: {'message': 'Not Found'});
      expect(f404, isA<NotFoundFailure>());

      final f422 = FailureMapper.map(statusCode: 422, data: {'message': 'Unprocessable'});
      expect(f422, isA<ValidationFailure>());

      final f500 = FailureMapper.map(statusCode: 500, data: {'message': 'Internal Server Error'});
      expect(f500, isA<ServerFailure>());
    });

    test('ErrorHandler maps DioException types accurately', () {
      const handler = ErrorHandler();
      final options = RequestOptions(path: '/test');

      final timeoutErr = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );
      expect(handler.handle(timeoutErr), isA<TimeoutFailure>());

      final connErr = DioException(requestOptions: options, type: DioExceptionType.connectionError);
      expect(handler.handle(connErr), isA<NetworkFailure>());

      final certErr = DioException(requestOptions: options, type: DioExceptionType.badCertificate);
      expect(handler.handle(certErr), isA<PinningFailure>());

      final cancelErr = DioException(requestOptions: options, type: DioExceptionType.cancel);
      expect(handler.handle(cancelErr), isA<CancelFailure>());

      final responseErr = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 401),
      );
      expect(handler.handle(responseErr), isA<AuthFailure>());
    });

    test('RefreshSessionWorkflow handles unauthorized and calls onExpired on failure', () async {
      var expiredCalled = false;
      final workflow = RefreshSessionWorkflow(
        refreshToken: () async => false, // Refresh gagal
        onSessionExpired: () async => expiredCalled = true,
      );

      final success = await workflow.onUnauthorized();
      expect(success, isFalse);
      expect(expiredCalled, isTrue);
    });

    test('ForceLogoutWorkflow executes onLogout', () async {
      var logoutCalled = false;
      final workflow = ForceLogoutWorkflow(onLogout: () async => logoutCalled = true);

      final ok = await workflow.onUnauthorized();
      expect(ok, isFalse);
      expect(logoutCalled, isTrue);
    });
  });
}
