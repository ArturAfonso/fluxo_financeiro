import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:flutter/material.dart';

final class DataFreshnessBanner extends StatelessWidget {
  const DataFreshnessBanner({
    required this.lastSynchronizedAt,
    required this.onRefresh,
    super.key,
  });

  final DateTime? lastSynchronizedAt;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF4E3511)
        : const Color(0xFFFFF0D5);
    final foreground = isDark
        ? const Color(0xFFFFE0A6)
        : const Color(0xFF674000);
    final updatedAt = lastSynchronizedAt == null
        ? 'em um momento anterior'
        : 'em ${FinancialFormatters.dateTime(lastSynchronizedAt!)}';
    final message =
        'Não foi possível atualizar. Exibindo dados sincronizados $updatedAt, que podem estar desatualizados.';

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            children: [
              Icon(Icons.sync_problem_outlined, color: foreground, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tentar atualizar',
                onPressed: onRefresh,
                color: foreground,
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
