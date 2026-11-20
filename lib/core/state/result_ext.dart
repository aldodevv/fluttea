import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ResultToAsyncValueX<T> on Result<T> {
  AsyncValue<T> toAsyncValue() => switch (this) {
    Ok(:final value) => AsyncData(value),
    Err(:final failure) => AsyncError(failure, failure.stackTrace ?? StackTrace.current),
  };

  T unwrapOrThrow() => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

extension FutureResultToAsyncValueX<T> on Future<Result<T>> {
  Future<AsyncValue<T>> toAsyncValue() async {
    final result = await this;
    return result.toAsyncValue();
  }

  Future<T> unwrapOrThrow() async {
    final result = await this;
    return result.unwrapOrThrow();
  }
}

extension AsyncValueFailureX<T> on AsyncValue<T> {
  Failure? get failureOrNull {
    final err = error;
    if (err is Failure) {
      return err;
    }
    return null;
  }
}
