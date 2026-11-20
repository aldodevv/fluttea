import 'package:fluttea/core/constants/response/error_codes.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure hierarchy', () {
    test('NetworkFailure has correct defaults', () {
      const failure = NetworkFailure();
      expect(failure.code, equals(ErrorCodes.network));
      expect(failure.message, contains('koneksi'));
    });

    test('TimeoutFailure has correct defaults', () {
      const failure = TimeoutFailure();
      expect(failure.code, equals(ErrorCodes.timeout));
    });

    test('ServerFailure holds status and payload', () {
      const failure = ServerFailure(statusCode: 503, payload: {'reason': 'maintenance'});
      expect(failure.code, equals(ErrorCodes.server));
      expect(failure.statusCode, equals(503));
      expect(failure.payload?['reason'], equals('maintenance'));
    });

    test('AuthFailure and ForbiddenFailure default status codes', () {
      const auth = AuthFailure();
      const forbidden = ForbiddenFailure();
      expect(auth.statusCode, equals(401));
      expect(forbidden.statusCode, equals(403));
    });

    test('ValidationFailure holds fieldErrors', () {
      const failure = ValidationFailure(fieldErrors: {'email': 'Email tidak valid'});
      expect(failure.code, equals(ErrorCodes.validation));
      expect(failure.fieldErrors['email'], equals('Email tidak valid'));
    });

    test('SecurityFailure and PinningFailure', () {
      const sec = SecurityFailure();
      const pin = PinningFailure();
      expect(sec.code, equals(ErrorCodes.tampered));
      expect(pin.code, equals(ErrorCodes.pinning));
    });

    test('Equality and toString', () {
      const f1 = NetworkFailure(message: 'Error A');
      const f2 = NetworkFailure(message: 'Error A');
      const f3 = NetworkFailure(message: 'Error B');

      expect(f1, equals(f2));
      expect(f1, isNot(equals(f3)));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1.toString(), contains('Failure('));
    });
  });
}
