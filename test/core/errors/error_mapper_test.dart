import 'dart:async';
import 'dart:io';

import 'package:fluttea/core/constants/response/error_codes.dart';
import 'package:fluttea/core/errors/error_mapper.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorMapper', () {
    test('returns original failure if error is already a Failure', () {
      const original = NetworkFailure();
      final mapped = ErrorMapper.fromException(original);
      expect(mapped, same(original));
    });

    test('maps SocketException to NetworkFailure', () {
      const socketEx = SocketException('Failed host lookup');
      final mapped = ErrorMapper.fromException(socketEx);
      expect(mapped, isA<NetworkFailure>());
      expect(mapped.code, equals(ErrorCodes.network));
      expect(mapped.cause, same(socketEx));
    });

    test('maps TimeoutException to TimeoutFailure', () {
      final timeoutEx = TimeoutException('Timed out');
      final mapped = ErrorMapper.fromException(timeoutEx);
      expect(mapped, isA<TimeoutFailure>());
      expect(mapped.code, equals(ErrorCodes.timeout));
    });

    test('maps FormatException to ParseFailure', () {
      const formatEx = FormatException('Invalid JSON');
      final mapped = ErrorMapper.fromException(formatEx);
      expect(mapped, isA<ParseFailure>());
      expect(mapped.code, equals(ErrorCodes.parse));
    });

    test('maps unknown exceptions to UnknownFailure', () {
      final ex = StateError('Bad state');
      final mapped = ErrorMapper.fromException(ex);
      expect(mapped, isA<UnknownFailure>());
      expect(mapped.code, equals(ErrorCodes.unknown));
      expect(mapped.cause, same(ex));
    });
  });
}
