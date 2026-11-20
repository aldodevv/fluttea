import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/state/result_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResultExt', () {
    test('toAsyncValue converts Ok to AsyncData and Err to AsyncError', () {
      const ok = Result.ok(100);
      final asyncData = ok.toAsyncValue();
      expect(asyncData, isA<AsyncData<int>>());
      expect(asyncData.value, equals(100));

      const err = Result<int>.err(NetworkFailure(message: 'Offline'));
      final asyncError = err.toAsyncValue();
      expect(asyncError, isA<AsyncError<int>>());
      expect(asyncError.error, isA<NetworkFailure>());
      expect(asyncError.failureOrNull?.message, equals('Offline'));
    });

    test('unwrapOrThrow returns value for Ok and throws Failure for Err', () {
      const ok = Result.ok('hello');
      expect(ok.unwrapOrThrow(), equals('hello'));

      const err = Result<String>.err(AuthFailure());
      expect(err.unwrapOrThrow, throwsA(isA<AuthFailure>()));
    });

    test('Future<Result<T>> extensions', () async {
      final futureOk = Future.value(const Result.ok(42));
      final asyncData = await futureOk.toAsyncValue();
      expect(asyncData.value, equals(42));

      final value = await futureOk.unwrapOrThrow();
      expect(value, equals(42));

      final futureErr = Future.value(const Result<int>.err(ServerFailure()));
      expect(futureErr.unwrapOrThrow, throwsA(isA<ServerFailure>()));
    });
  });
}
