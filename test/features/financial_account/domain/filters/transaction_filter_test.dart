import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionFilter', () {
    test('combina filtros e protege conjuntos contra alteração', () {
      final sourceTypes = {TransactionType.credit};
      final filter = TransactionFilter(
        types: sourceTypes,
        statuses: const {TransactionStatus.completed},
        descriptionQuery: ' mercado ',
      );

      sourceTypes.add(TransactionType.debit);

      expect(filter.types, {TransactionType.credit});
      expect(filter.descriptionQuery, 'mercado');
      expect(filter.isEmpty, isFalse);
      expect(
        () => filter.types.add(TransactionType.debit),
        throwsUnsupportedError,
      );
    });

    test('é igual independentemente da ordem dos conjuntos', () {
      final first = TransactionFilter(
        types: const {TransactionType.credit, TransactionType.debit},
      );
      final second = TransactionFilter(
        types: const {TransactionType.debit, TransactionType.credit},
      );

      expect(first, second);
    });

    test('página usa limite seguro e cursor não vazio', () {
      expect(TransactionPageRequest().limit, 20);
      expect(() => TransactionPageRequest(limit: 0), throwsRangeError);
      expect(() => TransactionPageRequest(limit: 101), throwsRangeError);
      expect(() => TransactionPageRequest(cursor: ' '), throwsArgumentError);
    });
  });
}
