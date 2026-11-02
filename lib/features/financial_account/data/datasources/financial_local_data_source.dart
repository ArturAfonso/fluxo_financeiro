import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fluxo_financeiro/features/financial_account/data/database/financial_database.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/dto_parsing_exception.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';

final class CachedLedger {
  const CachedLedger({required this.snapshot, required this.cachedAt});

  final LedgerSnapshot snapshot;
  final DateTime cachedAt;
}

abstract interface class FinancialLocalDataSource {
  Future<CachedLedger?> getLedger();

  Future<void> replaceLedger(LedgerSnapshot snapshot, DateTime cachedAt);

  Future<TransactionPage> getTransactions(TransactionQuery query);

  Future<FinancialTransaction?> getTransactionById(String id);
}

final class DriftFinancialLocalDataSource implements FinancialLocalDataSource {
  const DriftFinancialLocalDataSource(this.database);

  final FinancialDatabase database;

  @override
  Future<CachedLedger?> getLedger() async {
    final ledger = await database
        .select(database.ledgerRecords)
        .getSingleOrNull();
    if (ledger == null) {
      return null;
    }
    final rows =
        await (database.select(database.transactionRecords)..orderBy([
              (table) => OrderingTerm.desc(table.occurredAt),
              (table) => OrderingTerm.desc(table.id),
            ]))
            .get();
    return CachedLedger(
      snapshot: LedgerSnapshot(
        openingBalance: Money.fromCents(ledger.openingBalanceCents),
        openingBalanceAt: ledger.openingBalanceAt.toUtc(),
        asOf: ledger.asOf.toUtc(),
        transactions: rows.map(_mapRow).toList(),
      ),
      cachedAt: ledger.cachedAt.toUtc(),
    );
  }

  @override
  Future<void> replaceLedger(LedgerSnapshot snapshot, DateTime cachedAt) async {
    if (!cachedAt.isUtc) {
      throw ArgumentError.value(cachedAt, 'cachedAt', 'Must use UTC.');
    }
    await database.transaction(() async {
      await database.delete(database.transactionRecords).go();
      await database.delete(database.ledgerRecords).go();
      await database
          .into(database.ledgerRecords)
          .insert(
            LedgerRecordsCompanion.insert(
              openingBalanceCents: snapshot.openingBalance.cents,
              openingBalanceAt: snapshot.openingBalanceAt,
              asOf: snapshot.asOf,
              cachedAt: cachedAt,
            ),
          );
      await database.batch((batch) {
        batch.insertAll(
          database.transactionRecords,
          snapshot.transactions.map(_mapTransaction).toList(),
        );
      });
    });
  }

  @override
  Future<TransactionPage> getTransactions(TransactionQuery query) async {
    final cursor = _TransactionCursor.decode(query.page.cursor);
    final select = database.select(database.transactionRecords);
    final filter = query.filter;

    if (filter.types.isNotEmpty) {
      select.where(
        (table) => table.type.isIn(filter.types.map(_typeToJson).toList()),
      );
    }
    if (filter.statuses.isNotEmpty) {
      select.where(
        (table) =>
            table.status.isIn(filter.statuses.map(_statusToJson).toList()),
      );
    }
    if (filter.period case final period?) {
      select.where(
        (table) =>
            table.occurredAt.isBiggerOrEqualValue(period.startInclusive) &
            table.occurredAt.isSmallerThanValue(period.endExclusive),
      );
    }
    if (filter.descriptionQuery.isNotEmpty) {
      select.where(
        (table) => table.description.lower().contains(
          filter.descriptionQuery.toLowerCase(),
        ),
      );
    }
    if (cursor != null) {
      select.where(
        (table) =>
            table.occurredAt.isSmallerThanValue(cursor.occurredAt) |
            (table.occurredAt.equals(cursor.occurredAt) &
                table.id.isSmallerThanValue(cursor.id)),
      );
    }

    select
      ..orderBy([
        (table) => OrderingTerm.desc(table.occurredAt),
        (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(query.page.limit + 1);

    final rows = await select.get();
    final hasNextPage = rows.length > query.page.limit;
    final visibleRows = rows.take(query.page.limit).toList();
    final nextCursor = hasNextPage && visibleRows.isNotEmpty
        ? _TransactionCursor(
            occurredAt: visibleRows.last.occurredAt.toUtc(),
            id: visibleRows.last.id,
          ).encode()
        : null;

    return TransactionPage(
      items: visibleRows.map(_mapRow).toList(),
      nextCursor: nextCursor,
    );
  }

  @override
  Future<FinancialTransaction?> getTransactionById(String id) async {
    final row = await (database.select(
      database.transactionRecords,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  TransactionRecordsCompanion _mapTransaction(
    FinancialTransaction transaction,
  ) {
    return TransactionRecordsCompanion.insert(
      id: transaction.id,
      description: transaction.description,
      amountCents: transaction.amount.cents,
      occurredAt: transaction.occurredAt,
      type: _typeToJson(transaction.type),
      status: _statusToJson(transaction.status),
      metadataJson: Value(jsonEncode(transaction.metadata)),
    );
  }

  FinancialTransaction _mapRow(TransactionRecord row) {
    final metadataValue = jsonDecode(row.metadataJson);
    if (metadataValue is! Map) {
      throw const DtoParsingException('Stored metadata must be an object.');
    }
    final metadata = <String, String>{};
    for (final entry in metadataValue.entries) {
      if (entry.key is! String || entry.value is! String) {
        throw const DtoParsingException(
          'Stored metadata must contain strings.',
        );
      }
      metadata[entry.key as String] = entry.value as String;
    }
    return FinancialTransaction(
      id: row.id,
      description: row.description,
      amount: Money.fromCents(row.amountCents),
      occurredAt: row.occurredAt.toUtc(),
      type: switch (row.type) {
        'credit' => TransactionType.credit,
        'debit' => TransactionType.debit,
        _ => throw DtoParsingException('Unknown stored type: ${row.type}.'),
      },
      status: switch (row.status) {
        'completed' => TransactionStatus.completed,
        'pending' => TransactionStatus.pending,
        'failed' => TransactionStatus.failed,
        'reversed' => TransactionStatus.reversed,
        _ => throw DtoParsingException('Unknown stored status: ${row.status}.'),
      },
      metadata: metadata,
    );
  }
}

String _typeToJson(TransactionType type) => switch (type) {
  TransactionType.credit => 'credit',
  TransactionType.debit => 'debit',
};

String _statusToJson(TransactionStatus status) => switch (status) {
  TransactionStatus.completed => 'completed',
  TransactionStatus.pending => 'pending',
  TransactionStatus.failed => 'failed',
  TransactionStatus.reversed => 'reversed',
};

final class _TransactionCursor {
  const _TransactionCursor({required this.occurredAt, required this.id});

  final DateTime occurredAt;
  final String id;

  String encode() {
    return base64Url.encode(
      utf8.encode(jsonEncode({'at': occurredAt.toIso8601String(), 'id': id})),
    );
  }

  static _TransactionCursor? decode(String? value) {
    if (value == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(utf8.decode(base64Url.decode(value)));
      if (decoded is! Map ||
          decoded['at'] is! String ||
          decoded['id'] is! String) {
        throw const FormatException('Invalid cursor fields.');
      }
      final occurredAt = DateTime.parse(decoded['at'] as String);
      if (!occurredAt.isUtc) {
        throw const FormatException('Cursor date must be UTC.');
      }
      return _TransactionCursor(
        occurredAt: occurredAt,
        id: decoded['id'] as String,
      );
    } on FormatException {
      rethrow;
    } on Object {
      throw FormatException('Invalid transaction cursor.', value);
    }
  }
}
