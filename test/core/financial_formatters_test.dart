import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('formata moeda e instante em pt-BR usando o fuso local', () {
    expect(
      FinancialFormatters.currency(const Money.fromCents(123456)),
      contains('1.234,56'),
    );
    expect(
      FinancialFormatters.dateTime(DateTime.utc(2026, 11, 1, 12)),
      contains('01/11/2026'),
    );
  });
}
