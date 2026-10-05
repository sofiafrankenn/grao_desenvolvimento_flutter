import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/micro_copy.dart';
import '../widgets/balance_card.dart';
import '../widgets/donut_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/goal_card.dart';
import '../widgets/grao_logo.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_sheet.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onSeeHistory,
    required this.onSeeGoals,
  });

  final VoidCallback onSeeHistory;
  final VoidCallback onSeeGoals;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recent = state.monthTransactions.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(state: state)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionTitle('Pra onde foi seu dinheiro'),
                const SizedBox(height: 12),
                _ChartCard(state: state),
                if (state.goals.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionTitle(
                    'Suas metas',
                    actionLabel: 'Ver todas',
                    onAction: onSeeGoals,
                  ),
                  const SizedBox(height: 12),
                  ..._topGoals(state),
                ],
                const SizedBox(height: 18),
                _SectionTitle(
                  'Últimas anotações',
                  actionLabel: 'Ver tudo',
                  onAction: onSeeHistory,
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  EmptyState(
                    icon: Icons.edit_note_rounded,
                    title: 'Nada anotado em ${monthName(state.month.month).toLowerCase()}',
                    message: 'Toque em "Anotar" pra registrar o primeiro.',
                  )
                else
                  ...recent.map(
                    (t) => TransactionTile(
                      transaction: t,
                      onTap: () => showTransactionSheet(context, t),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// As 3 metas mais perto de estourar (ou já estouradas).
  List<Widget> _topGoals(AppState state) {
    final items = state.goals.toList()
      ..sort((a, b) {
        final ra = state.spentIn(a.categoryId) / a.limit;
        final rb = state.spentIn(b.categoryId) / b.limit;
        return rb.compareTo(ra);
      });
    return items.take(3).map((Goal g) {
      return GoalCard(
        category: AppCategories.byId(g.categoryId),
        spent: state.spentIn(g.categoryId),
        limit: g.limit,
        onTap: onSeeGoals,
      );
    }).toList();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final name = state.name;
    final hello = name.isEmpty ? greeting(now) : '${greeting(now)}, $name';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 12,
        bottom: 24,
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GraoLogo(size: 26),
              MonthSelector(),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hello,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  MicroCopy.homeSummary(state),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                BalanceCard(
                  balance: state.monthBalance,
                  income: state.monthIncome,
                  expense: state.monthExpense,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ranking = state.monthExpenseRanking;

    if (ranking.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const EmptyState(
          icon: Icons.donut_large_rounded,
          title: 'Sem gastos nesse mês',
          message: 'Quando você anotar um gasto, o gráfico aparece aqui.',
        ),
      );
    }

    final slices = ranking
        .map((e) => DonutSlice(
              value: e.value,
              color: AppCategories.byId(e.key).color,
            ))
        .toList();
    final legend = ranking.take(4).toList();
    final extra = ranking.length - legend.length;
    final insight = MicroCopy.chartInsight(state);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DonutChart(
                size: 136,
                slices: slices,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Saiu',
                      style: TextStyle(fontSize: 11, color: AppColors.textGray),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatMoney(state.monthExpense),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in legend)
                      _LegendRow(
                        category: AppCategories.byId(e.key),
                        percent: (e.value / state.monthExpense * 100).round(),
                      ),
                    if (extra > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '+ $extra ${extra == 1 ? 'categoria' : 'categorias'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (insight.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              insight,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.category, required this.percent});

  final Category category;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
