import 'package:dio/dio.dart';
import 'package:fluxo_financeiro/core/network/retry_policy.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/ledger_dto.dart';

abstract interface class FinancialRemoteDataSource {
  Future<LedgerDto> fetchLedger({CancelToken? cancelToken});
}

final class DioFinancialRemoteDataSource implements FinancialRemoteDataSource {
  const DioFinancialRemoteDataSource({
    required this.dio,
    this.retryPolicy = const RetryPolicy(),
  });

  final Dio dio;
  final RetryPolicy retryPolicy;

  @override
  Future<LedgerDto> fetchLedger({CancelToken? cancelToken}) async {
    final response = await retryPolicy.get<Object?>(
      dio,
      '/v1/ledger',
      cancelToken: cancelToken,
    );
    return LedgerDto.fromJson(response.data);
  }
}
