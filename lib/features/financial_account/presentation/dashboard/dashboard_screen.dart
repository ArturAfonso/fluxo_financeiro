import 'package:fl_chart/fl_chart.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/failure_message.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/message_state.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão geral'),
        actions: const [_ThemeToggle()],
      ),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listenWhen: (previous, current) =>
            previous.failure != current.failure &&
            current.failure != null &&
            current.summary != null,
        listener: (context, state) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failureMessage(state.failure!)))),
        builder: (context, state) {
          if (state.status == DashboardStatus.loading &&
              state.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DashboardStatus.failure &&
              state.summary == null) {
            return MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'Não foi possível carregar',
              message: failureMessage(state.failure!),
              actionLabel: 'Tentar novamente',
              onAction: context.read<DashboardCubit>().load,
            );
          }
          final summary = state.summary;
          if (summary == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: context.read<DashboardCubit>().refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _BalanceCard(summary: summary, state: state),
                const SizedBox(height: 16),
                _PeriodSelector(selectedMonth: state.selectedMonth!),
                const SizedBox(height: 12),
                _Totals(summary: summary),
                const SizedBox(height: 16),
                _MovementChart(summary: summary),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transações recentes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed('statement'),
                      child: const Text('Ver extrato'),
                    ),
                  ],
                ),
                if (state.recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Nenhuma transação encontrada.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...state.recentTransactions.map(
                    (transaction) => TransactionTile(transaction: transaction),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoNext = selectedMonth.isBefore(DateTime(now.year, now.month));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Mês anterior',
          onPressed: () => context.read<DashboardCubit>().changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        SizedBox(
          width: 160,
          child: Text(
            FinancialFormatters.monthYear(selectedMonth),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Próximo mês',
          onPressed: canGoNext
              ? () => context.read<DashboardCubit>().changeMonth(1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

final class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.state});

  final AccountSummary summary;
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo disponível',
                    style: TextStyle(color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: state.balanceVisible
                        ? 'Saldo disponível, ${FinancialFormatters.currency(summary.availableBalance)}'
                        : 'Saldo oculto',
                    child: Text(
                      state.balanceVisible
                          ? FinancialFormatters.currency(
                              summary.availableBalance,
                            )
                          : '••••••',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Atualizado em ${FinancialFormatters.dateTime(summary.calculatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: state.balanceVisible ? 'Ocultar saldo' : 'Mostrar saldo',
              onPressed: context.read<DashboardCubit>().toggleBalanceVisibility,
              icon: Icon(
                state.balanceVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Totals extends StatelessWidget {
  const _Totals({required this.summary});

  final AccountSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TotalCard(
            label: 'Entradas',
            amount: FinancialFormatters.currency(summary.totalCredits),
            icon: Icons.south_west,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TotalCard(
            label: 'Saídas',
            amount: FinancialFormatters.currency(summary.totalDebits),
            icon: Icons.north_east,
          ),
        ),
      ],
    );
  }
}

final class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final String amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(label),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _MovementChart extends StatelessWidget {
  const _MovementChart({required this.summary});

  final AccountSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movimentação do mês',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Semantics(
              label:
                  'Gráfico: entradas ${FinancialFormatters.currency(summary.totalCredits)}; '
                  'saídas ${FinancialFormatters.currency(summary.totalDebits)}',
              child: SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _chartMaximum(summary),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => scheme.inverseSurface,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final isCredit = group.x == 0;
                          final label = isCredit ? 'Entradas' : 'Saídas';
                          final amount = isCredit
                              ? summary.totalCredits
                              : summary.totalDebits;
                          return BarTooltipItem(
                            '$label\n${FinancialFormatters.currency(amount)}',
                            TextStyle(
                              color: scheme.onInverseSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(value == 0 ? 'Entradas' : 'Saídas'),
                          ),
                        ),
                      ),
                    ),
                    barGroups: [
                      _group(
                        0,
                        summary.totalCredits.cents / 100,
                        scheme.primary,
                      ),
                      _group(1, summary.totalDebits.cents / 100, scheme.error),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _chartMaximum(AccountSummary summary) {
    final maximum = summary.totalCredits.cents > summary.totalDebits.cents
        ? summary.totalCredits.cents
        : summary.totalDebits.cents;
    return maximum == 0 ? 1 : maximum / 100 * 1.2;
  }

  BarChartGroupData _group(int x, double value, Color color) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 36,
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
}

final class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state.mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Ativar tema claro' : 'Ativar tema escuro',
          onPressed: context.read<ThemeCubit>().toggle,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        );
      },
    );
  }
}
