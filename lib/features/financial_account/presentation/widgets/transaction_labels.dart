import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';

extension TransactionTypeLabel on TransactionType {
  String get label => switch (this) {
    TransactionType.credit => 'Entrada',
    TransactionType.debit => 'Saída',
  };
}

extension TransactionStatusLabel on TransactionStatus {
  String get label => switch (this) {
    TransactionStatus.completed => 'Concluída',
    TransactionStatus.pending => 'Pendente',
    TransactionStatus.failed => 'Falhou',
    TransactionStatus.reversed => 'Estornada',
  };
}
