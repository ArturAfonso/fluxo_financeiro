import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transactions.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/refresh_financial_data.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final class MockFinancialRepository extends Mock
    implements FinancialRepository {}

void main() {
  late MockFinancialRepository repository;

  setUpAll(() {
    registerFallbackValue(
      TransactionQuery(
        filter: TransactionFilter(),
        page: TransactionPageRequest(),
      ),
    );
  });

  setUp(() {
    repository = MockFinancialRepository();
  });

  group('GetAccountSummary', () {
    test('calcula o resumo a partir do snapshot do repositório', () async {
      final snapshot = LedgerSnapshot(
        openingBalance: const Money.fromCents(1000),
        openingBalanceAt: DateTime.utc(2026, 1, 1),
        asOf: DateTime.utc(2026, 1, 31),
        transactions: [_transaction],
      );
      final period = UtcDateRange(
        startInclusive: DateTime.utc(2026, 1, 1),
        endExclusive: DateTime.utc(2026, 2, 1),
      );
      when(
        repository.getLedgerSnapshot,
      ).thenAnswer((_) async => Success(snapshot));

      final result = await GetAccountSummary(repository: repository)(period);

      expect(
        result.fold(
          onSuccess: (summary) => summary.availableBalance,
          onFailure: (_) => null,
        ),
        const Money.fromCents(1500),
      );
      verify(repository.getLedgerSnapshot).called(1);
    });

    test('propaga falha tipada do repositório', () async {
      const failure = OfflineFailure();
      when(
        repository.getLedgerSnapshot,
      ).thenAnswer((_) async => const FailureResult(failure));
      final period = UtcDateRange(
        startInclusive: DateTime.utc(2026, 1, 1),
        endExclusive: DateTime.utc(2026, 2, 1),
      );

      final result = await GetAccountSummary(repository: repository)(period);

      expect(
        result.fold(onSuccess: (_) => null, onFailure: (value) => value),
        failure,
      );
    });
  });

  test('GetTransactions encaminha o filtro e a paginação', () async {
    final query = TransactionQuery(
      filter: TransactionFilter(types: const {TransactionType.credit}),
      page: TransactionPageRequest(limit: 10),
    );
    final page = TransactionPage(items: [_transaction], nextCursor: 'next');
    when(
      () => repository.getTransactions(query),
    ).thenAnswer((_) async => Success(page));

    final result = await GetTransactions(repository)(query);

    expect(result, Success(page));
    verify(() => repository.getTransactions(query)).called(1);
  });

  group('GetTransactionDetails', () {
    test('normaliza o identificador antes de consultar', () async {
      when(() => repository.getTransactionById('tx-1')).thenAnswer(
        (_) async => Success(TransactionDetails(transaction: _transaction)),
      );

      final result = await GetTransactionDetails(repository)(' tx-1 ');

      expect(result, Success(TransactionDetails(transaction: _transaction)));
      verify(() => repository.getTransactionById('tx-1')).called(1);
    });

    test('rejeita identificador vazio sem acessar o repositório', () async {
      final result = await GetTransactionDetails(repository)(' ');

      expect(
        result,
        const FailureResult<TransactionDetails>(
          ValidationFailure(field: 'transactionId'),
        ),
      );
      verifyNever(() => repository.getTransactionById(any()));
    });
  });

  test('RefreshFinancialData encaminha a atualização', () async {
    when(
      () => repository.refresh(replaceInFlight: any(named: 'replaceInFlight')),
    ).thenAnswer((_) async => const Success(null));

    final result = await RefreshFinancialData(repository)(
      replaceInFlight: true,
    );

    expect(result, const Success<void>(null));
    verify(() => repository.refresh(replaceInFlight: true)).called(1);
  });
}

final _transaction = FinancialTransaction(
  id: 'tx-1',
  description: 'Recebimento',
  amount: const Money.fromCents(500),
  occurredAt: DateTime.utc(2026, 1, 10),
  type: TransactionType.credit,
  status: TransactionStatus.completed,
);
