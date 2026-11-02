import 'package:fl_chart/fl_chart.dart';
import 'package:fluxo_financeiro/app/theme/app_theme.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/failure_message.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/data_freshness_banner.dart';
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
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.failure != current.failure &&
              current.failure != null &&
              current.summary != null,
          listener: (context, state) =>
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failureMessage(state.failure!))),
              ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  const _DashboardHeader(),
                  const SizedBox(height: 20),
                  if (summary.isStale) ...[
                    DataFreshnessBanner(
                      lastSynchronizedAt: summary.lastSynchronizedAt,
                      onRefresh: context.read<DashboardCubit>().refresh,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _BalanceCard(summary: summary, state: state),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Fluxo do período',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _PeriodSelector(selectedMonth: state.selectedMonth!),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MovementChart(summary: summary),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recentes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.goNamed('statement'),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ver extrato'),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
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
                      (transaction) =>
                          TransactionTile(transaction: transaction),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.lime,
          foregroundColor: AppTheme.deepPetroleum,
          child: Text('FF', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá,',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(
                'Fluxo Financeiro',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const _ThemeToggle(),
      ],
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Mês anterior',
            visualDensity: VisualDensity.compact,
            onPressed: () => context.read<DashboardCubit>().changeMonth(-1),
            icon: const Icon(Icons.chevron_left, size: 20),
          ),
          Text(
            FinancialFormatters.monthYear(selectedMonth),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          IconButton(
            tooltip: 'Próximo mês',
            visualDensity: VisualDensity.compact,
            onPressed: canGoNext
                ? () => context.read<DashboardCubit>().changeMonth(1)
                : null,
            icon: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }
}

final class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.state});

  final AccountSummary summary;
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.petroleum,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Saldo disponível',
                    style: TextStyle(color: Color(0xFFB9CEC7)),
                  ),
                ),
                IconButton(
                  tooltip: state.balanceVisible
                      ? 'Ocultar saldo'
                      : 'Mostrar saldo',
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                  onPressed: context
                      .read<DashboardCubit>()
                      .toggleBalanceVisibility,
                  icon: Icon(
                    state.balanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Semantics(
              label: state.balanceVisible
                  ? 'Saldo disponível, ${FinancialFormatters.currency(summary.availableBalance)}'
                  : 'Saldo oculto',
              child: Text(
                state.balanceVisible
                    ? FinancialFormatters.currency(summary.availableBalance)
                    : 'R\$ ••••••',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Atualizado em ${FinancialFormatters.dateTime(summary.calculatedAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFB9CEC7)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _TotalCard(
                    label: 'Entradas',
                    amount: state.balanceVisible
                        ? FinancialFormatters.currency(summary.totalCredits)
                        : 'R\$ •••',
                    icon: Icons.south_west,
                    iconColor: AppTheme.lime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TotalCard(
                    label: 'Saídas',
                    amount: state.balanceVisible
                        ? FinancialFormatters.currency(summary.totalDebits)
                        : 'R\$ •••',
                    icon: Icons.north_east,
                    iconColor: const Color(0xFFFFC66D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFB9CEC7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
    final creditColor = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.lime
        : AppTheme.emerald;
    const debitColor = Color(0xFFE58A2B);
    final points = _chartPoints(summary.dailyCashFlow);
    final isWeekly = summary.dailyCashFlow.length > 7;
    final maximum = _chartMaximum(points);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ChartLegend(color: creditColor, label: 'Entradas'),
                const SizedBox(width: 16),
                const _ChartLegend(color: debitColor, label: 'Saídas'),
                const Spacer(),
                Text(
                  isWeekly ? 'Por semana' : 'Por dia',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              label:
                  'Gráfico de evolução ${isWeekly ? 'semanal' : 'diária'}: entradas ${FinancialFormatters.currency(summary.totalCredits)}; '
                  'saídas ${FinancialFormatters.currency(summary.totalDebits)}',
              child: SizedBox(
                height: 168,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: maximum,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => scheme.inverseSurface,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final point = points[group.x];
                          final isCredit = rodIndex == 0;
                          final label = isCredit ? 'Entradas' : 'Saídas';
                          final amount = Money.fromCents(
                            isCredit ? point.creditCents : point.debitCents,
                          );
                          return BarTooltipItem(
                            '${_tooltipPeriod(point)}\n'
                            '$label: ${FinancialFormatters.currency(amount)}',
                            TextStyle(
                              color: scheme.onInverseSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: maximum / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: scheme.outlineVariant.withValues(alpha: 0.45),
                        strokeWidth: 1,
                        dashArray: const [4, 5],
                      ),
                    ),
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
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) =>
                              _dayTitle(context, value.toInt(), points),
                        ),
                      ),
                    ),
                    barGroups: List.generate(points.length, (index) {
                      final point = points[index];
                      return _group(
                        index,
                        point.creditCents / 100,
                        point.debitCents / 100,
                        creditColor,
                        debitColor,
                        scheme.surfaceContainerHighest,
                        maximum,
                        points.length,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ChartPeriod> _chartPoints(List<DailyCashFlow> dailyPoints) {
    if (dailyPoints.length <= 7) {
      return dailyPoints
          .map(
            (point) => _ChartPeriod(
              start: point.dayStart,
              end: point.dayStart,
              creditCents: point.credits.cents,
              debitCents: point.debits.cents,
            ),
          )
          .toList(growable: false);
    }

    final periods = <_ChartPeriod>[];
    for (var start = 0; start < dailyPoints.length; start += 7) {
      final end = (start + 7).clamp(0, dailyPoints.length);
      final week = dailyPoints.sublist(start, end);
      periods.add(
        _ChartPeriod(
          start: week.first.dayStart,
          end: week.last.dayStart,
          creditCents: week.fold(0, (total, day) => total + day.credits.cents),
          debitCents: week.fold(0, (total, day) => total + day.debits.cents),
        ),
      );
    }
    return periods;
  }

  double _chartMaximum(List<_ChartPeriod> points) {
    var maximum = 0;
    for (final point in points) {
      if (point.creditCents > maximum) maximum = point.creditCents;
      if (point.debitCents > maximum) maximum = point.debitCents;
    }
    return maximum == 0 ? 1 : maximum / 100 * 1.2;
  }

  Widget _dayTitle(BuildContext context, int index, List<_ChartPeriod> points) {
    if (index < 0 || index >= points.length) return const SizedBox.shrink();
    final point = points[index];
    final start = point.start.toLocal();
    final end = point.end.toLocal();
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        start.day == end.day
            ? '${start.day.toString().padLeft(2, '0')} ${months[start.month - 1]}'
            : '${start.day.toString().padLeft(2, '0')}–${end.day.toString().padLeft(2, '0')}',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _tooltipPeriod(_ChartPeriod point) {
    final start = FinancialFormatters.date(point.start);
    if (point.start == point.end) return start;
    return '$start – ${FinancialFormatters.date(point.end)}';
  }

  BarChartGroupData _group(
    int x,
    double credits,
    double debits,
    Color creditColor,
    Color debitColor,
    Color backgroundColor,
    double maximum,
    int pointCount,
  ) {
    final width = pointCount <= 7
        ? 16.0
        : pointCount <= 16
        ? 6.0
        : 3.5;
    return BarChartGroupData(
      x: x,
      barsSpace: pointCount <= 7
          ? 7
          : pointCount <= 16
          ? 3
          : 1.5,
      barRods: [
        BarChartRodData(
          toY: credits,
          width: width,
          color: creditColor,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maximum,
            color: backgroundColor.withValues(alpha: 0.55),
          ),
        ),
        BarChartRodData(
          toY: debits,
          width: width,
          color: debitColor,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maximum,
            color: backgroundColor.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

final class _ChartPeriod {
  const _ChartPeriod({
    required this.start,
    required this.end,
    required this.creditCents,
    required this.debitCents,
  });

  final DateTime start;
  final DateTime end;
  final int creditCents;
  final int debitCents;
}

final class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
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
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          onPressed: context.read<ThemeCubit>().toggle,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        );
      },
    );
  }
}
