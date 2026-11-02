import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';

enum TransactionType { credit, debit }

enum TransactionStatus { completed, pending, failed, reversed }

final class FinancialTransaction extends Equatable {
  FinancialTransaction({
    required String id,
    required String description,
    required this.amount,
    required this.occurredAt,
    required this.type,
    required this.status,
    Map<String, String> metadata = const {},
  }) : id = id.trim(),
       description = description.trim(),
       metadata = UnmodifiableMapView(Map.of(metadata)) {
    if (this.id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
    if (this.description.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'Must not be empty.',
      );
    }
    if (amount.isNegative) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Transaction amount must be zero or positive.',
      );
    }
    if (!occurredAt.isUtc) {
      throw ArgumentError.value(occurredAt, 'occurredAt', 'Must use UTC.');
    }
  }

  final String id;
  final String description;
  final Money amount;
  final DateTime occurredAt;
  final TransactionType type;
  final TransactionStatus status;
  final Map<String, String> metadata;

  bool get affectsBalance => status == TransactionStatus.completed;

  Money get signedAmount {
    return switch (type) {
      TransactionType.credit => amount,
      TransactionType.debit => -amount,
    };
  }

  @override
  List<Object?> get props => [
    id,
    description,
    amount,
    occurredAt,
    type,
    status,
    metadata,
  ];
}
