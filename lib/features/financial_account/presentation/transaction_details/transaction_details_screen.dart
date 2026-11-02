import 'package:fluxo_financeiro/app/theme/app_theme.dart';
import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/failure_message.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/data_freshness_banner.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/message_state.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/transaction_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Detalhes da transação'),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      body: BlocBuilder<TransactionDetailsCubit, TransactionDetailsState>(
        builder: (context, state) {
          return switch (state.status) {
            TransactionDetailsStatus.initial ||
            TransactionDetailsStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            TransactionDetailsStatus.failure => MessageState(
              icon: Icons.error_outline,
              title: 'Transação indisponível',
              message: failureMessage(state.failure!),
              actionLabel: 'Tentar novamente',
              onAction: context.read<TransactionDetailsCubit>().load,
            ),
            TransactionDetailsStatus.success => Column(
              children: [
                if (state.isStale)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: DataFreshnessBanner(
                      lastSynchronizedAt: state.lastSynchronizedAt,
                      onRefresh: context.read<TransactionDetailsCubit>().load,
                    ),
                  ),
                Expanded(child: _Details(transaction: state.transaction!)),
              ],
            ),
          };
        },
      ),
    );
  }
}

final class _Details extends StatelessWidget {
  const _Details({required this.transaction});

  final FinancialTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final scheme = Theme.of(context).colorScheme;
    final amountColor = isCredit
        ? (Theme.of(context).brightness == Brightness.dark
              ? AppTheme.lime
              : AppTheme.emerald)
        : scheme.error;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isCredit
                    ? scheme.primaryContainer
                    : scheme.errorContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                isCredit ? Icons.south_west : Icons.north_east,
                size: 32,
                color: isCredit
                    ? scheme.onPrimaryContainer
                    : scheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              transaction.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${isCredit ? '+' : '-'} ${FinancialFormatters.currency(transaction.amount)}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _StatusPill(status: transaction.status),
          ],
        ),
        const SizedBox(height: 28),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                _DetailRow(label: 'Tipo', value: transaction.type.label),
                _DetailRow(
                  label: 'Data e hora',
                  value: FinancialFormatters.dateTime(transaction.occurredAt),
                ),
              ],
            ),
          ),
        ),
        if (transaction.metadata.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Informações adicionais',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: transaction.metadata.entries
                    .map(
                      (entry) => _DetailRow(
                        label: _metadataLabel(entry.key),
                        value: entry.value,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IDENTIFICADOR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      transaction.id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Copiar Identificador',
                    onPressed: () => _copy(context, transaction.id),
                    icon: const Icon(Icons.copy_outlined, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Identificador copiado.')));
    }
  }

  String _metadataLabel(String value) => switch (value) {
    'sender' => 'Remetente',
    'merchant' => 'Estabelecimento',
    'category' => 'Categoria',
    'reason' => 'Motivo',
    'channel' => 'Canal',
    _ => value,
  };
}

final class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

final class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (status) {
      TransactionStatus.completed => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check,
      ),
      TransactionStatus.pending => (
        const Color(0xFFFFE4B5),
        const Color(0xFF6B4300),
        Icons.schedule,
      ),
      TransactionStatus.failed => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.close,
      ),
      TransactionStatus.reversed => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        Icons.undo,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
