import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/dto_parsing_exception.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/transaction_dto.dart';

final class LedgerDto extends Equatable {
  const LedgerDto({
    required this.openingBalanceCents,
    required this.openingBalanceAt,
    required this.asOf,
    required this.transactions,
  });

  factory LedgerDto.fromJson(Object? json) {
    final root = requireJsonMap(json, 'response');
    final data = requireJsonMap(root['data'], 'data');
    final transactionsJson = data['transactions'];
    if (transactionsJson is! List) {
      throw DtoParsingException(
        'transactions must be an array.',
        source: transactionsJson,
      );
    }

    return LedgerDto(
      openingBalanceCents: requireJsonInt(data, 'opening_balance_cents'),
      openingBalanceAt: requireJsonUtcDateTime(data, 'opening_balance_at'),
      asOf: requireJsonUtcDateTime(data, 'as_of'),
      transactions: List.unmodifiable(
        transactionsJson.map(TransactionDto.fromJson),
      ),
    );
  }

  final int openingBalanceCents;
  final DateTime openingBalanceAt;
  final DateTime asOf;
  final List<TransactionDto> transactions;

  @override
  List<Object?> get props => [
    openingBalanceCents,
    openingBalanceAt,
    asOf,
    transactions,
  ];
}
