import 'package:fluxo_financeiro/features/financial_account/data/dtos/dto_parsing_exception.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/ledger_dto.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/transaction_dto.dart';
import 'package:fluxo_financeiro/features/financial_account/data/mappers/financial_mappers.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data_test_fixtures.dart';

void main() {
  group('LedgerDto', () {
    test('faz parsing defensivo e mapeia para o domínio', () {
      final dto = LedgerDto.fromJson(ledgerJsonFixture());
      final snapshot = dto.toDomain();

      expect(snapshot.openingBalance.cents, 100000);
      expect(snapshot.transactions, hasLength(1));
      expect(snapshot.transactions.single.type, TransactionType.debit);
      expect(snapshot.transactions.single.metadata, {'source': 'test'});
    });

    test('rejeita double em campos monetários', () {
      final json = ledgerJsonFixture();
      final data = json['data']! as Map<String, Object?>;
      data['opening_balance_cents'] = 1000.0;

      expect(
        () => LedgerDto.fromJson(json),
        throwsA(isA<DtoParsingException>()),
      );
    });

    test('rejeita data sem marcador UTC', () {
      final json = ledgerJsonFixture();
      final data = json['data']! as Map<String, Object?>;
      data['as_of'] = '2026-11-01T00:00:00';

      expect(
        () => LedgerDto.fromJson(json),
        throwsA(isA<DtoParsingException>()),
      );
    });

    test('rejeita metadado que não seja texto', () {
      final json = ledgerJsonFixture();
      final data = json['data']! as Map<String, Object?>;
      final transactions = data['transactions']! as List<Object?>;
      final transaction = transactions.single as Map<String, Object?>;
      transaction['metadata'] = {'installments': 2};

      expect(
        () => LedgerDto.fromJson(json),
        throwsA(isA<DtoParsingException>()),
      );
    });

    test('rejeita enums desconhecidos no mapper', () {
      expect(
        () => ledgerDtoFixture(type: 'pix').toDomain(),
        throwsA(isA<DtoParsingException>()),
      );
      expect(
        () => ledgerDtoFixture(status: 'cancelled').toDomain(),
        throwsA(isA<DtoParsingException>()),
      );
    });

    test('converte invariantes financeiras inválidas em erro de parsing', () {
      final dto = ledgerDtoFixture();
      final invalid = LedgerDto(
        openingBalanceCents: dto.openingBalanceCents,
        openingBalanceAt: dto.openingBalanceAt,
        asOf: dto.asOf,
        transactions: [
          TransactionDto(
            id: dto.transactions.single.id,
            description: dto.transactions.single.description,
            amountCents: -1,
            occurredAt: dto.transactions.single.occurredAt,
            type: dto.transactions.single.type,
            status: dto.transactions.single.status,
            metadata: dto.transactions.single.metadata,
          ),
        ],
      );

      expect(() => invalid.toDomain(), throwsA(isA<DtoParsingException>()));
    });
  });
}
