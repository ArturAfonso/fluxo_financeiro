import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialTransaction', () {
    test('normaliza texto e protege os metadados contra alteração', () {
      final sourceMetadata = {'merchant': 'Mercado'};
      final transaction = FinancialTransaction(
        id: ' tx-1 ',
        description: ' Compra ',
        amount: const Money.fromCents(1099),
        occurredAt: DateTime.utc(2026, 1, 1),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        metadata: sourceMetadata,
      );

      sourceMetadata['merchant'] = 'Alterado';

      expect(transaction.id, 'tx-1');
      expect(transaction.description, 'Compra');
      expect(transaction.metadata, {'merchant': 'Mercado'});
      expect(
        () => transaction.metadata['merchant'] = 'Outro',
        throwsUnsupportedError,
      );
      expect(transaction.signedAmount, const Money.fromCents(-1099));
      expect(transaction.affectsBalance, isTrue);
    });

    test('somente status concluído afeta o saldo', () {
      for (final status in [
        TransactionStatus.pending,
        TransactionStatus.failed,
        TransactionStatus.reversed,
      ]) {
        final transaction = FinancialTransaction(
          id: status.name,
          description: status.name,
          amount: const Money.fromCents(100),
          occurredAt: DateTime.utc(2026, 1, 1),
          type: TransactionType.credit,
          status: status,
        );

        expect(transaction.affectsBalance, isFalse);
      }
    });

    test('rejeita valor negativo, campos vazios e data não UTC', () {
      FinancialTransaction build({
        String id = 'tx',
        String description = 'Compra',
        Money amount = const Money.fromCents(100),
        DateTime? occurredAt,
      }) => FinancialTransaction(
        id: id,
        description: description,
        amount: amount,
        occurredAt: occurredAt ?? DateTime.utc(2026),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
      );

      expect(() => build(id: ' '), throwsArgumentError);
      expect(() => build(description: ' '), throwsArgumentError);
      expect(
        () => build(amount: const Money.fromCents(-1)),
        throwsArgumentError,
      );
      expect(() => build(occurredAt: DateTime(2026)), throwsArgumentError);
    });
  });
}
