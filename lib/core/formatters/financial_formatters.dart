import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:intl/intl.dart';

abstract final class FinancialFormatters {
  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );
  static final _date = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dateTime = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
  static final _dayHeader = DateFormat("dd 'de' MMMM", 'pt_BR');
  static final _monthYear = DateFormat('MMMM yyyy', 'pt_BR');

  static String currency(Money value) => _currency.format(value.cents / 100);

  static String date(DateTime value) => _date.format(value.toLocal());

  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());

  static String dayHeader(DateTime value) => _dayHeader.format(value.toLocal());

  static String monthYear(DateTime value) => _monthYear.format(value.toLocal());
}
