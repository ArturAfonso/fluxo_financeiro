import 'package:dio/dio.dart';
import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_local_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_remote_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/dto_parsing_exception.dart';
import 'package:fluxo_financeiro/features/financial_account/data/mappers/financial_mappers.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';

typedef RepositoryClock = DateTime Function();

final class FinancialRepositoryImpl implements FinancialRepository {
  FinancialRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.cacheTtl = const Duration(minutes: 5),
    RepositoryClock? clock,
  }) : clock = clock ?? _utcNow;

  final FinancialLocalDataSource localDataSource;
  final FinancialRemoteDataSource remoteDataSource;
  final Duration cacheTtl;
  final RepositoryClock clock;

  Future<Result<void>>? _refreshInFlight;

  @override
  Future<Result<LedgerSnapshot>> getLedgerSnapshot() async {
    CachedLedger? cached;
    try {
      cached = await localDataSource.getLedger();
    } on Object {
      final refreshResult = await refresh();
      if (refreshResult case FailureResult<void>(:final failure)) {
        return FailureResult(failure);
      }
      return _readLedgerAfterRefresh();
    }

    if (cached == null) {
      final refreshResult = await refresh();
      if (refreshResult case FailureResult<void>(:final failure)) {
        return FailureResult(failure);
      }
      return _readLedgerAfterRefresh();
    }

    final age = clock().difference(cached.cachedAt);
    if (age <= cacheTtl && !age.isNegative) {
      return Success(cached.snapshot);
    }

    final refreshResult = await refresh();
    if (refreshResult is FailureResult<void>) {
      return Success(cached.snapshot);
    }
    return _readLedgerAfterRefresh(fallback: cached.snapshot);
  }

  @override
  Future<Result<TransactionPage>> getTransactions(
    TransactionQuery query,
  ) async {
    final readiness = await getLedgerSnapshot();
    if (readiness case FailureResult<LedgerSnapshot>(:final failure)) {
      return FailureResult(failure);
    }
    try {
      return Success(await localDataSource.getTransactions(query));
    } on FormatException {
      return const FailureResult(ValidationFailure(field: 'cursor'));
    } on Object {
      return const FailureResult(CacheFailure());
    }
  }

  @override
  Future<Result<FinancialTransaction>> getTransactionById(String id) async {
    final readiness = await getLedgerSnapshot();
    if (readiness case FailureResult<LedgerSnapshot>(:final failure)) {
      return FailureResult(failure);
    }
    try {
      final transaction = await localDataSource.getTransactionById(id);
      return transaction == null
          ? FailureResult(
              NotFoundFailure(resource: 'transaction', identifier: id),
            )
          : Success(transaction);
    } on Object {
      return const FailureResult(CacheFailure());
    }
  }

  @override
  Future<Result<void>> refresh() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }
    late final Future<Result<void>> operation;
    operation = _performRefresh().whenComplete(() {
      if (identical(_refreshInFlight, operation)) {
        _refreshInFlight = null;
      }
    });
    _refreshInFlight = operation;
    return operation;
  }

  Future<Result<void>> _performRefresh() async {
    try {
      final dto = await remoteDataSource.fetchLedger();
      final snapshot = dto.toDomain();
      await localDataSource.replaceLedger(snapshot, clock());
      return const Success(null);
    } on DtoParsingException {
      return const FailureResult(ParsingFailure());
    } on FormatException {
      return const FailureResult(ParsingFailure());
    } on ArgumentError {
      return const FailureResult(ParsingFailure());
    } on DioException catch (error) {
      return FailureResult(_mapDioFailure(error));
    } on Object {
      return const FailureResult(UnexpectedFailure());
    }
  }

  Future<Result<LedgerSnapshot>> _readLedgerAfterRefresh({
    LedgerSnapshot? fallback,
  }) async {
    try {
      final refreshed = await localDataSource.getLedger();
      if (refreshed != null) {
        return Success(refreshed.snapshot);
      }
      return fallback == null
          ? const FailureResult(CacheFailure())
          : Success(fallback);
    } on Object {
      return fallback == null
          ? const FailureResult(CacheFailure())
          : Success(fallback);
    }
  }

  Failure _mapDioFailure(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 429) {
      final seconds = int.tryParse(
        error.response?.headers.value('retry-after') ?? '',
      );
      return RateLimitFailure(
        retryAfter: seconds == null ? null : Duration(seconds: seconds),
      );
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const OfflineFailure();
    }
    return const NetworkFailure();
  }

  static DateTime _utcNow() => DateTime.now().toUtc();
}
