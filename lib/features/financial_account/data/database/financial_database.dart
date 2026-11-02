import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'financial_database.g.dart';

class LedgerRecords extends Table {
  IntColumn get singleton => integer().withDefault(const Constant(1))();
  IntColumn get openingBalanceCents => integer()();
  DateTimeColumn get openingBalanceAt => dateTime()();
  DateTimeColumn get asOf => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {singleton};
}

class TransactionRecords extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [LedgerRecords, TransactionRecords])
final class FinancialDatabase extends _$FinancialDatabase {
  FinancialDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fluxo_financeiro'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE INDEX transaction_order_idx '
        'ON transaction_records (occurred_at DESC, id DESC)',
      );
      await customStatement(
        'CREATE INDEX transaction_filter_idx '
        'ON transaction_records (type, status, occurred_at DESC)',
      );
    },
  );
}
