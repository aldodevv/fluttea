import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok holds value and flags isOk', () {
      const result = Result.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.dataOrNull, equals(42));
      expect(result.failureOrNull, isNull);
      expect(result.getOrElse((_) => 0), equals(42));
    });

    test('Err holds failure and flags isErr', () {
      const failure = NetworkFailure();
      const result = Result<int>.err(failure);
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, equals(failure));
      expect(result.getOrElse((_) => 99), equals(99));
    });

    test('when branches correctly', () {
      const ok = Result.ok('success');
      const err = Result<String>.err(ServerFailure());

      final okMsg = ok.when(ok: (val) => 'val: $val', err: (fail) => 'fail: ${fail.code}');
      final errMsg = err.when(ok: (val) => 'val: $val', err: (fail) => 'fail: ${fail.code}');

      expect(okMsg, equals('val: success'));
      expect(errMsg, equals('fail: ERR_SERVER'));
    });

    test('map and flatMap transform Ok value', () {
      const ok = Result.ok(10);
      final mapped = ok.map((val) => val * 2);
      expect(mapped.dataOrNull, equals(20));

      final flatMapped = ok.flatMap((val) => Result.ok('num: $val'));
      expect(flatMapped.dataOrNull, equals('num: 10'));
    });

    test('map and flatMap preserve Err', () {
      const err = Result<int>.err(AuthFailure());
      final mapped = err.map((val) => val * 2);
      expect(mapped.isErr, isTrue);
      expect(mapped.failureOrNull, isA<AuthFailure>());

      final flatMapped = err.flatMap((val) => Result.ok('num: $val'));
      expect(flatMapped.isErr, isTrue);
    });

    test('mapAsync and flatMapAsync support async transformations', () async {
      const ok = Result.ok(5);
      final mappedAsync = await ok.mapAsync((val) async => val + 15);
      expect(mappedAsync.dataOrNull, equals(20));

      final flatMappedAsync = await ok.flatMapAsync((val) async => Result.ok(val * 3));
      expect(flatMappedAsync.dataOrNull, equals(15));
    });

    test('Result.of catches Failure and Exceptions', () {
      final success = Result.of(() => 'done');
      expect(success.isOk, isTrue);
      expect(success.dataOrNull, equals('done'));

      final fail = Result.of(() => throw const NetworkFailure());
      expect(fail.isErr, isTrue);
      expect(fail.failureOrNull, isA<NetworkFailure>());

      final ex = Result.of(() => throw Exception('error'));
      expect(ex.isErr, isTrue);
      expect(ex.failureOrNull, isA<UnknownFailure>());
    });

    test('Result.fromAsync catches async failures', () async {
      final success = await Result.fromAsync(() async => 'done async');
      expect(success.isOk, isTrue);
      expect(success.dataOrNull, equals('done async'));

      final fail = await Result.fromAsync(() async => throw const ServerFailure());
      expect(fail.isErr, isTrue);
      expect(fail.failureOrNull, isA<ServerFailure>());
    });

    test('Equality and toString', () {
      expect(const Result.ok(1), equals(const Result.ok(1)));
      expect(const Result.ok(1), isNot(equals(const Result.ok(2))));
      expect(const Result.ok(1).toString(), equals('Ok(1)'));

      const fail = NetworkFailure();
      expect(const Result<int>.err(fail), equals(const Result<int>.err(fail)));
      expect(const Result<int>.err(fail).toString(), contains('Err('));
    });
  });
}
