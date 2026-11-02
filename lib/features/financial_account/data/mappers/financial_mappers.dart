import 'package:fluxo_financeiro/features/financial_account/data/dtos/dto_parsing_exception.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/ledger_dto.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/transaction_dto.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';

extension TransactionDtoMapper on TransactionDto {
  FinancialTransaction toDomain() {
    return FinancialTransaction(
      id: id,
      description: description,
      amount: Money.fromCents(amountCents),
      occurredAt: occurredAt,
      type: switch (type) {
        'credit' => TransactionType.credit,
        'debit' => TransactionType.debit,
        _ => throw DtoParsingException('Unknown transaction type: $type.'),
      },
      status: switch (status) {
        'completed' => TransactionStatus.completed,
        'pending' => TransactionStatus.pending,
        'failed' => TransactionStatus.failed,
        'reversed' => TransactionStatus.reversed,
        _ => throw DtoParsingException('Unknown transaction status: $status.'),
      },
      metadata: metadata,
    );
  }
}

extension LedgerDtoMapper on LedgerDto {
  LedgerSnapshot toDomain() {
    try {
      return LedgerSnapshot(
        openingBalance: Money.fromCents(openingBalanceCents),
        openingBalanceAt: openingBalanceAt,
        asOf: asOf,
        transactions: transactions.map((dto) => dto.toDomain()).toList(),
      );
    } on ArgumentError catch (error) {
      throw DtoParsingException('Invalid financial payload.', source: error);
    }
  }
}
