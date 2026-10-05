import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/micro_copy.dart';
import '../widgets/goal_card.dart';
import '../widgets/month_selector.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    // Categorias com meta primeiro (as mais apertadas no topo); depois as sem meta.
    final withGoal = AppCategories.expenses
        .where((c) => state.goalFor(c.id) != null)
        .toList()
      ..sort((a, b) {
        final ra = state.spentIn(a.id) / state.goalFor(a.id)!.limit;
        final rb = state.spentIn(b.id) / state.goalFor(b.id)!.limit;
        return rb.compareTo(ra);
      });
    final withoutGoal = AppCategories.expenses
        .where((c) => state.goalFor(c.id) == null)
        .toList();

    final okCount = withGoal
        .where((c) => state.spentIn(c.id) <= state.goalFor(c.id)!.limit)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 12,
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [MonthSelector()],
                  ),
                  const Text(
                    'Metas',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      MicroCopy.goalsSummary(okCount, withGoal.length),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                for (final c in withGoal)
                  GoalCard(
                    category: c,
                    spent: state.spentIn(c.id),
                    limit: state.goalFor(c.id)!.limit,
                    onTap: () => showGoalSheet(context, c),
                  ),
                if (withoutGoal.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Sem meta',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                  for (final c in withoutGoal)
                    GoalCard(
                      category: c,
                      spent: state.spentIn(c.id),
                      limit: null,
                      onTap: () => showGoalSheet(context, c),
                    ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Folha para definir, mudar ou remover a meta de uma categoria.
Future<void> showGoalSheet(BuildContext context, Category category) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _GoalSheet(category: category),
  );
}

class _GoalSheet extends StatefulWidget {
  const _GoalSheet({required this.category});

  final Category category;

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = AppScope.read(context).goalFor(widget.category.id);
    if (current != null) {
      final s = current.limit.toStringAsFixed(2).replaceAll('.', ',');
      _controller.text = s.endsWith(',00') ? s.substring(0, s.length - 3) : s;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value =
        double.tryParse(_controller.text.trim().replaceAll(',', '.')) ?? 0;
    if (value <= 0) {
      setState(() => _error = 'Coloca um valor maior que zero.');
      return;
    }
    final state = AppScope.read(context);
    final nav = Navigator.of(context);
    await state.saveGoal(Goal(categoryId: widget.category.id, limit: value));
    nav.pop();
  }

  Future<void> _remove() async {
    final state = AppScope.read(context);
    final nav = Navigator.of(context);
    await state.deleteGoal(widget.category.id);
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cat = widget.category;
    final hasGoal = state.goalFor(cat.id) != null;
    final spent = state.spentIn(cat.id);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cat.lightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat.icon, color: cat.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta de ${cat.name}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Já foram ${formatMoney(spent)} em ${monthName(state.month.month).toLowerCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  labelText: 'Quanto você topa gastar por mês?',
                  prefixText: 'R\$ ',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (hasGoal) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _remove,
                        child: const Text('Tirar meta'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Salvar meta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
