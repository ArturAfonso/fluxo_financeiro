import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/failure_message.dart';
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
      appBar: AppBar(title: const Text('Detalhes da transação')),
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
            TransactionDetailsStatus.success => _Details(
              transaction: state.transaction!,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: isCredit ? scheme.primaryContainer : scheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(isCredit ? Icons.south_west : Icons.north_east, size: 40),
                const SizedBox(height: 12),
                Text(
                  '${isCredit ? '+' : '-'} ${FinancialFormatters.currency(transaction.amount)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(transaction.description, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _DetailRow(label: 'Tipo', value: transaction.type.label),
                _DetailRow(label: 'Status', value: transaction.status.label),
                _DetailRow(
                  label: 'Data e hora',
                  value: FinancialFormatters.dateTime(transaction.occurredAt),
                ),
                _DetailRow(
                  label: 'Identificador',
                  value: transaction.id,
                  onCopy: () => _copy(context, transaction.id),
                ),
              ],
            ),
          ),
        ),
        if (transaction.metadata.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Informações adicionais',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
  const _DetailRow({required this.label, required this.value, this.onCopy});

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: onCopy == null
          ? null
          : IconButton(
              tooltip: 'Copiar $label',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
            ),
    );
  }
}
