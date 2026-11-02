import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/core/errors/failure.dart';

sealed class Result<T> extends Equatable {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  });

  Result<R> map<R>(R Function(T value) transform) {
    return fold(
      onSuccess: (value) => Success(transform(value)),
      onFailure: FailureResult.new,
    );
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => onSuccess(value);

  @override
  List<Object?> get props => [value];
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => onFailure(failure);

  @override
  List<Object?> get props => [failure];
}
