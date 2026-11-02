import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('página protege itens e indica a existência da próxima página', () {
    final source = [_transaction];
    final page = TransactionPage(items: source, nextCursor: 'next');

    source.clear();

    expect(page.items, [_transaction]);
    expect(page.hasNextPage, isTrue);
    expect(() => page.items.clear(), throwsUnsupportedError);
    expect(TransactionPage(items: const []).hasNextPage, isFalse);
  });
}

final _transaction = FinancialTransaction(
  id: 'tx-1',
  description: 'Transação',
  amount: const Money.fromCents(100),
  occurredAt: DateTime.utc(2026, 1, 1),
  type: TransactionType.credit,
  status: TransactionStatus.completed,
);
