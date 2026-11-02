import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super('network');
}

final class OfflineFailure extends Failure {
  const OfflineFailure() : super('offline');
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure({this.retryAfter}) : super('rate_limit');

  final Duration? retryAfter;

  @override
  List<Object?> get props => [...super.props, retryAfter];
}

final class CacheFailure extends Failure {
  const CacheFailure() : super('cache');
}

final class ParsingFailure extends Failure {
  const ParsingFailure() : super('parsing');
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({required this.resource, required this.identifier})
    : super('not_found');

  final String resource;
  final String identifier;

  @override
  List<Object?> get props => [...super.props, resource, identifier];
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required this.field}) : super('validation');

  final String field;

  @override
  List<Object?> get props => [...super.props, field];
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('unexpected');
}
