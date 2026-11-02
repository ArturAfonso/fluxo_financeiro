import 'dart:ffi';

import 'package:drift/native.dart';
import 'package:fluxo_financeiro/features/financial_account/data/database/financial_database.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_local_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data_test_fixtures.dart';

void main() {
  final sqliteSkip = _hasSqliteLibrary()
      ? false
      : 'libsqlite3 não está disponível neste host de testes.';

  group('DriftFinancialLocalDataSource', () {
    late FinancialDatabase database;
    late DriftFinancialLocalDataSource dataSource;

    setUp(() {
      database = FinancialDatabase(NativeDatabase.memory());
      dataSource = DriftFinancialLocalDataSource(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('grava e lê o snapshot atomicamente', () async {
      final snapshot = ledgerFixture();
      final cachedAt = DateTime.utc(2026, 11, 1, 12);

      await dataSource.replaceLedger(snapshot, cachedAt);
      final cached = await dataSource.getLedger();

      expect(cached?.snapshot, snapshot);
      expect(cached?.cachedAt, cachedAt);
    });

    test('substitui transações antigas sem deixar registros órfãos', () async {
      await dataSource.replaceLedger(
        ledgerFixture(
          transactions: [
            transactionFixture(id: 'old'),
            transactionFixture(id: 'removed'),
          ],
        ),
        DateTime.utc(2026, 11, 1),
      );
      await dataSource.replaceLedger(
        ledgerFixture(transactions: [transactionFixture(id: 'new')]),
        DateTime.utc(2026, 11, 2),
      );

      expect(await dataSource.getTransactionById('old'), isNull);
      expect(await dataSource.getTransactionById('removed'), isNull);
      expect(await dataSource.getTransactionById('new'), isNotNull);
    });

    test('combina filtros e busca sem diferenciar maiúsculas', () async {
      await dataSource.replaceLedger(
        ledgerFixture(
          transactions: [
            transactionFixture(
              id: 'wanted',
              description: 'Compra no MERCADO',
              occurredAt: DateTime.utc(2026, 10, 20),
            ),
            transactionFixture(
              id: 'pending',
              description: 'Compra no mercado',
              occurredAt: DateTime.utc(2026, 10, 20),
              status: TransactionStatus.pending,
            ),
            transactionFixture(
              id: 'credit',
              description: 'Mercado devolução',
              occurredAt: DateTime.utc(2026, 10, 20),
              type: TransactionType.credit,
            ),
            transactionFixture(
              id: 'outside',
              description: 'Compra no mercado',
              occurredAt: DateTime.utc(2026, 10, 1),
            ),
          ],
        ),
        DateTime.utc(2026, 11, 1),
      );
      final query = TransactionQuery(
        filter: TransactionFilter(
          types: const {TransactionType.debit},
          statuses: const {TransactionStatus.completed},
          period: UtcDateRange(
            startInclusive: DateTime.utc(2026, 10, 10),
            endExclusive: DateTime.utc(2026, 11, 1),
          ),
          descriptionQuery: 'mercado',
        ),
        page: TransactionPageRequest(),
      );

      final page = await dataSource.getTransactions(query);

      expect(page.items.map((item) => item.id), ['wanted']);
    });

    test('pagina por cursor sem repetir itens de mesma data', () async {
      final occurredAt = DateTime.utc(2026, 10, 20);
      await dataSource.replaceLedger(
        ledgerFixture(
          transactions: [
            transactionFixture(id: 'tx-3', occurredAt: occurredAt),
            transactionFixture(id: 'tx-2', occurredAt: occurredAt),
            transactionFixture(id: 'tx-1', occurredAt: occurredAt),
          ],
        ),
        DateTime.utc(2026, 11, 1),
      );
      final first = await dataSource.getTransactions(
        TransactionQuery(
          filter: TransactionFilter(),
          page: TransactionPageRequest(limit: 2),
        ),
      );
      final second = await dataSource.getTransactions(
        TransactionQuery(
          filter: TransactionFilter(),
          page: TransactionPageRequest(cursor: first.nextCursor, limit: 2),
        ),
      );

      expect(first.items.map((item) => item.id), ['tx-3', 'tx-2']);
      expect(first.hasNextPage, isTrue);
      expect(second.items.map((item) => item.id), ['tx-1']);
      expect(second.hasNextPage, isFalse);
    });

    test('rejeita cursor adulterado', () async {
      expect(
        () => dataSource.getTransactions(
          TransactionQuery(
            filter: TransactionFilter(),
            page: TransactionPageRequest(cursor: 'invalid'),
          ),
        ),
        throwsFormatException,
      );
    });

    test('rejeita instante de cache sem UTC', () async {
      expect(
        () => dataSource.replaceLedger(ledgerFixture(), DateTime(2026, 11, 1)),
        throwsArgumentError,
      );
    });
  }, skip: sqliteSkip);
}

bool _hasSqliteLibrary() {
  try {
    DynamicLibrary.open('libsqlite3.so').close();
    return true;
  } on ArgumentError {
    return false;
  }
}
