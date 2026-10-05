import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_sheet.dart';
import '../widgets/transaction_tile.dart';

enum _TypeFilter { all, expenses, incomes }

enum _Period { thisMonth, lastMonth, all }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _TypeFilter _type = _TypeFilter.all;
  _Period _period = _Period.thisMonth;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _inPeriod(DateTime d) {
    final now = DateTime.now();
    switch (_period) {
      case _Period.all:
        return true;
      case _Period.thisMonth:
        return d.year == now.year && d.month == now.month;
      case _Period.lastMonth:
        final last = DateTime(now.year, now.month - 1);
        return d.year == last.year && d.month == last.month;
    }
  }

  List<Transaction> _filtered(AppState state) {
    final q = _query.trim().toLowerCase();
    return state.transactions.where((t) {
      if (!_inPeriod(t.date)) return false;
      if (_type == _TypeFilter.expenses && !t.isExpense) return false;
      if (_type == _TypeFilter.incomes && t.isExpense) return false;
      if (q.isEmpty) return true;
      return t.title.toLowerCase().contains(q) ||
          t.category.name.toLowerCase().contains(q) ||
          (t.note ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// Agrupa por dia mantendo a ordem (mais recente primeiro).
  List<MapEntry<DateTime, List<Transaction>>> _groupByDay(
      List<Transaction> list) {
    final map = <DateTime, List<Transaction>>{};
    for (final t in list) {
      map.putIfAbsent(dayOnly(t.date), () => []).add(t);
    }
    return map.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final list = _filtered(state);
    final groups = _groupByDay(list);
    final net = list.fold<double>(
      0,
      (s, t) => s + (t.isExpense ? -t.amount : t.amount),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chipRow<_TypeFilter>(
                    values: _TypeFilter.values,
                    selected: _type,
                    label: (v) => switch (v) {
                      _TypeFilter.all => 'Tudo',
                      _TypeFilter.expenses => 'Gastos',
                      _TypeFilter.incomes => 'Entradas',
                    },
                    color: (v) => switch (v) {
                      _TypeFilter.all => AppColors.primary,
                      _TypeFilter.expenses => AppColors.expense,
                      _TypeFilter.incomes => AppColors.income,
                    },
                    onSelected: (v) => setState(() => _type = v),
                  ),
                  const SizedBox(height: 8),
                  _chipRow<_Period>(
                    values: _Period.values,
                    selected: _period,
                    label: (v) => switch (v) {
                      _Period.thisMonth => 'Este mês',
                      _Period.lastMonth => 'Mês passado',
                      _Period.all => 'Desde o início',
                    },
                    color: (_) => AppColors.primaryDark,
                    onSelected: (v) => setState(() => _period = v),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        list.length == 1
                            ? '1 anotação'
                            : '${list.length} anotações',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                      if (list.isNotEmpty)
                        Text(
                          'Saldo: ${formatMoney(net)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: net >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (groups.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Nada por aqui',
                message: _query.isNotEmpty
                    ? 'Não achei nada com "$_query". Tenta outra palavra.'
                    : 'Não tem anotação nesse filtro ainda.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = groups[index];
                    return _DayGroup(day: entry.key, items: entry.value);
                  },
                  childCount: groups.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chipRow<T>({
    required List<T> values,
    required T selected,
    required String Function(T) label,
    required Color Function(T) color,
    required void Function(T) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final v in values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: label(v),
                active: v == selected,
                color: color(v),
                onTap: () => onSelected(v),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 22,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Tudo que entrou e saiu',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Buscar por nome, categoria...',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.textGray),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textGray),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppColors.textGray,
          ),
        ),
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.day, required this.items});

  final DateTime day;
  final List<Transaction> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(
      0,
      (s, t) => s + (t.isExpense ? -t.amount : t.amount),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dayLabel(day),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textGray,
              ),
            ),
            Text(
              formatMoney(total, showSign: true),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: total >= 0 ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final t in items)
          Dismissible(
            key: ValueKey('tx-${t.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: AppColors.expense,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white),
            ),
            onDismissed: (_) => deleteWithUndo(context, t),
            child: TransactionTile(
              transaction: t,
              showDate: false,
              onTap: () => showTransactionSheet(context, t),
            ),
          ),
      ],
    );
  }
}
