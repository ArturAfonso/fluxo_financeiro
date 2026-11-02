import 'package:fluxo_financeiro/features/financial_account/data/dtos/ledger_dto.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/transaction_dto.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';

FinancialTransaction transactionFixture({
  String id = 'tx-1',
  String description = 'Compra no mercado',
  int cents = 1000,
  DateTime? occurredAt,
  TransactionType type = TransactionType.debit,
  TransactionStatus status = TransactionStatus.completed,
}) {
  return FinancialTransaction(
    id: id,
    description: description,
    amount: Money.fromCents(cents),
    occurredAt: occurredAt ?? DateTime.utc(2026, 10, 20),
    type: type,
    status: status,
    metadata: const {'source': 'test'},
  );
}

LedgerSnapshot ledgerFixture({List<FinancialTransaction>? transactions}) {
  return LedgerSnapshot(
    openingBalance: const Money.fromCents(100000),
    openingBalanceAt: DateTime.utc(2026, 10, 1),
    asOf: DateTime.utc(2026, 11, 1),
    transactions: transactions ?? [transactionFixture()],
  );
}

LedgerDto ledgerDtoFixture({
  String type = 'debit',
  String status = 'completed',
}) {
  return LedgerDto(
    openingBalanceCents: 100000,
    openingBalanceAt: DateTime.utc(2026, 10, 1),
    asOf: DateTime.utc(2026, 11, 1),
    transactions: [
      TransactionDto(
        id: 'tx-1',
        description: 'Compra no mercado',
        amountCents: 1000,
        occurredAt: DateTime.utc(2026, 10, 20),
        type: type,
        status: status,
        metadata: const {'source': 'test'},
      ),
    ],
  );
}

Map<String, Object?> ledgerJsonFixture() => {
  'data': {
    'opening_balance_cents': 100000,
    'opening_balance_at': '2026-10-01T00:00:00Z',
    'as_of': '2026-11-01T00:00:00Z',
    'transactions': [
      {
        'id': 'tx-1',
        'description': 'Compra no mercado',
        'amount_cents': 1000,
        'occurred_at': '2026-10-20T12:00:00Z',
        'type': 'debit',
        'status': 'completed',
        'metadata': {'source': 'test'},
      },
    ],
  },
};
