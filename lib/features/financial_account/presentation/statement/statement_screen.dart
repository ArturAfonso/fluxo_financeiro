import 'package:fluxo_financeiro/core/formatters/financial_formatters.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/statement/statement_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/failure_message.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/data_freshness_banner.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/message_state.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/transaction_labels.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

final class _StatementScreenState extends State<StatementScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<StatementCubit>();
    _searchController = TextEditingController(
      text: cubit.state.filter?.descriptionQuery,
    );
    _scrollController = ScrollController()..addListener(_onScroll);
    if (cubit.state.status == StatementStatus.initial) {
      cubit.load();
    }
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      context.read<StatementCubit>().load(reset: false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<StatementCubit, StatementState>(
          listenWhen: (previous, current) =>
              previous.failure != current.failure &&
              current.failure != null &&
              current.items.isNotEmpty,
          listener: (context, state) =>
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failureMessage(state.failure!))),
              ),
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Text(
                    'Extrato',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _SearchAndFilters(
                  controller: _searchController,
                  filter: state.filter ?? TransactionFilter(),
                  onShowFilters: () => _showFilters(context, state.filter),
                ),
                if (state.isStale)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                    child: DataFreshnessBanner(
                      lastSynchronizedAt: state.lastSynchronizedAt,
                      onRefresh: context.read<StatementCubit>().refresh,
                    ),
                  ),
                Expanded(child: _buildContent(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StatementState state) {
    if (state.status == StatementStatus.loading && state.items.isEmpty) {
      return const _StatementSkeleton();
    }
    if (state.status == StatementStatus.failure && state.items.isEmpty) {
      return MessageState(
        icon: Icons.cloud_off_outlined,
        title: 'Não foi possível carregar o extrato',
        message: failureMessage(state.failure!),
        actionLabel: 'Tentar novamente',
        onAction: context.read<StatementCubit>().load,
      );
    }
    if (state.items.isEmpty) {
      return MessageState(
        icon: Icons.search_off,
        title: 'Nenhum resultado',
        message: 'Ajuste a busca ou os filtros para encontrar transações.',
        actionLabel: 'Limpar filtros',
        onAction: () {
          _searchController.clear();
          context.read<StatementCubit>().clearFilters();
        },
      );
    }

    final rows = _groupedRows(state.items);
    return RefreshIndicator(
      onRefresh: context.read<StatementCubit>().refresh,
      child: ListView.builder(
        key: const PageStorageKey('statement-list'),
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount:
            rows.length +
            (state.isLoadingMore || (state.failure != null && state.hasNextPage)
                ? 1
                : 0),
        itemBuilder: (context, index) {
          if (index == rows.length) {
            if (!state.isLoadingMore) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        context.read<StatementCubit>().load(reset: false),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar carregar mais'),
                  ),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return rows[index];
        },
      ),
    );
  }

  List<Widget> _groupedRows(List<FinancialTransaction> items) {
    final rows = <Widget>[];
    DateTime? previousDay;
    for (final transaction in items) {
      final local = transaction.occurredAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day != previousDay) {
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
            child: Text(
              FinancialFormatters.dayHeader(day).toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        );
        previousDay = day;
      }
      rows.add(TransactionTile(transaction: transaction));
    }
    return rows;
  }

  Future<void> _showFilters(
    BuildContext context,
    TransactionFilter? currentFilter,
  ) async {
    final cubit = context.read<StatementCubit>();
    var types = Set<TransactionType>.of(currentFilter?.types ?? {});
    var statuses = Set<TransactionStatus>.of(currentFilter?.statuses ?? {});
    var period = currentFilter?.period;

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filtros',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tipo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TransactionType.values
                      .map(
                        (type) => FilterChip(
                          label: Text(type.label),
                          selected: types.contains(type),
                          onSelected: (selected) => setSheetState(() {
                            selected ? types.add(type) : types.remove(type);
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: TransactionStatus.values
                      .map(
                        (status) => FilterChip(
                          label: Text(status.label),
                          selected: statuses.contains(status),
                          onSelected: (selected) => setSheetState(() {
                            selected
                                ? statuses.add(status)
                                : statuses.remove(status);
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: ListTile(
                    leading: const Icon(Icons.date_range_outlined),
                    title: const Text('Período'),
                    subtitle: Text(
                      period == null
                          ? 'Todas as datas'
                          : '${FinancialFormatters.date(period!.startInclusive)} a '
                                '${FinancialFormatters.date(period!.endExclusive.subtract(const Duration(days: 1)))}',
                    ),
                    trailing: period == null
                        ? const Icon(Icons.chevron_right)
                        : IconButton(
                            tooltip: 'Limpar período',
                            onPressed: () => setSheetState(() => period = null),
                            icon: const Icon(Icons.clear),
                          ),
                    onTap: () async {
                      final now = DateTime.now();
                      final selected = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 1),
                        initialDateRange: period == null
                            ? null
                            : DateTimeRange(
                                start: period!.startInclusive.toLocal(),
                                end: period!.endExclusive
                                    .subtract(const Duration(days: 1))
                                    .toLocal(),
                              ),
                      );
                      if (selected != null) {
                        setSheetState(() {
                          period = UtcDateRange(
                            startInclusive: DateTime(
                              selected.start.year,
                              selected.start.month,
                              selected.start.day,
                            ).toUtc(),
                            endExclusive: DateTime(
                              selected.end.year,
                              selected.end.month,
                              selected.end.day + 1,
                            ).toUtc(),
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setSheetState(() {
                          types = {};
                          statuses = {};
                          period = null;
                        }),
                        child: const Text('Limpar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          cubit.setFilters(
                            types: types,
                            statuses: statuses,
                            period: period,
                          );
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.filter,
    required this.onShowFilters,
  });

  final TextEditingController controller;
  final TransactionFilter filter;
  final VoidCallback onShowFilters;

  @override
  Widget build(BuildContext context) {
    final activeFilters =
        filter.types.length +
        filter.statuses.length +
        (filter.period == null ? 0 : 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: context.read<StatementCubit>().search,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por descrição',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Badge(
                isLabelVisible: activeFilters > 0,
                label: Text('$activeFilters'),
                child: IconButton.filled(
                  tooltip: 'Filtrar extrato',
                  onPressed: onShowFilters,
                  icon: const Icon(Icons.tune),
                ),
              ),
            ],
          ),
          if (activeFilters > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...filter.types.map(
                  (type) => InputChip(
                    label: Text(type.label),
                    onDeleted: () {
                      final updated = Set<TransactionType>.of(filter.types)
                        ..remove(type);
                      context.read<StatementCubit>().setTypes(updated);
                    },
                  ),
                ),
                ...filter.statuses.map(
                  (status) => InputChip(
                    label: Text(status.label),
                    onDeleted: () {
                      final updated = Set<TransactionStatus>.of(filter.statuses)
                        ..remove(status);
                      context.read<StatementCubit>().setStatuses(updated);
                    },
                  ),
                ),
                if (filter.period != null)
                  InputChip(
                    label: Text(
                      '${FinancialFormatters.date(filter.period!.startInclusive)} – '
                      '${FinancialFormatters.date(filter.period!.endExclusive.subtract(const Duration(days: 1)))}',
                    ),
                    onDeleted: () =>
                        context.read<StatementCubit>().setPeriod(null),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

final class _StatementSkeleton extends StatelessWidget {
  const _StatementSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainer;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Container(
          height: 14,
          width: 96,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < 6; index++) ...[
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.55,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
