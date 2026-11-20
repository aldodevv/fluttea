import 'package:fluttea/core/errors/failure.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class Result<T> {
  const new();

  const factory ok(T value) = Ok<T>;
  const factory err(Failure failure) = Err<T>;

  factory of(T Function() computation) {
    try {
      return Result.ok(computation());
    } on Failure catch (failure) {
      return Result.err(failure);
    } on Object catch (e, st) {
      return Result.err(UnknownFailure(cause: e, stackTrace: st));
    }
  }

  static Future<Result<T>> fromAsync<T>(Future<T> Function() computation) async {
    try {
      final value = await computation();
      return Result.ok(value);
    } on Failure catch (failure) {
      return Result.err(failure);
    } on Object catch (e, st) {
      return Result.err(UnknownFailure(cause: e, stackTrace: st));
    }
  }

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get dataOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  R when<R>({required R Function(T value) ok, required R Function(Failure failure) err}) =>
      switch (this) {
        Ok(:final value) => ok(value),
        Err(:final failure) => err(failure),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Result.ok(transform(value)),
    Err(:final failure) => Result.err(failure),
  };

  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) transform) async => switch (this) {
    Ok(:final value) => Result.ok(await transform(value)),
    Err(:final failure) => Result.err(failure),
  };

  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Ok(:final value) => transform(value),
    Err(:final failure) => Result.err(failure),
  };

  Future<Result<R>> flatMapAsync<R>(Future<Result<R>> Function(T value) transform) async =>
      switch (this) {
        Ok(:final value) => await transform(value),
        Err(:final failure) => Result.err(failure),
      };

  T getOrElse(T Function(Failure failure) fallback) => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => fallback(failure),
  };
}

@immutable
final class Ok<T> extends Result<T> {
  const new(this.value);

  final T value;

  @override
  String toString() => 'Ok($value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ok<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

@immutable
final class Err<T> extends Result<T> {
  const new(this.failure);

  final Failure failure;

  @override
  String toString() => 'Err($failure)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Err<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;
}
