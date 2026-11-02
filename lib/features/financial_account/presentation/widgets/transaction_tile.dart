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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.pushNamed(
          'transactionDetails',
          pathParameters: {'transactionId': transaction.id},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isCredit
                      ? scheme.primaryContainer
                      : scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCredit ? Icons.south_west : Icons.north_east,
                  color: isCredit
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            FinancialFormatters.date(transaction.occurredAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 7),
                        _StatusLabel(status: transaction.status),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                signedAmount,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isCredit
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFC6F36A)
                            : scheme.tertiary)
                      : scheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      TransactionStatus.completed => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      TransactionStatus.pending => (
        const Color(0xFFFFE4B5),
        const Color(0xFF6B4300),
      ),
      TransactionStatus.failed => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      TransactionStatus.reversed => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
