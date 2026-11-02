import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/transaction_labels.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class TransactionTile extends StatelessWidget {
  const TransactionTile({required this.transaction, super.key});

  final FinancialTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final amount = FinancialFormatters.currency(transaction.amount);
    final signedAmount = '${isCredit ? '+' : '-'} $amount';
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label:
          '${transaction.description}, ${transaction.type.label}, '
          '$signedAmount, ${transaction.status.label}',
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? scheme.primaryContainer
              : scheme.errorContainer,
          child: Icon(
            isCredit ? Icons.south_west : Icons.north_east,
            color: isCredit
                ? scheme.onPrimaryContainer
                : scheme.onErrorContainer,
          ),
        ),
        title: Text(
          transaction.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${FinancialFormatters.date(transaction.occurredAt)} · '
          '${transaction.status.label}',
        ),
        trailing: Text(
          signedAmount,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isCredit ? scheme.primary : scheme.error,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: () => context.pushNamed(
          'transactionDetails',
          pathParameters: {'transactionId': transaction.id},
        ),
      ),
    );
  }
}
