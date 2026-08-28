import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
 
String _formatCurrency(double value) {
  final abs = value.abs();
  final formatted = abs.toStringAsFixed(2);
  final parts = formatted.split('.');
  String intPart = parts[0];
  final decPart = parts[1];
  final buffer = StringBuffer();
  int count = 0;
  for (int i = intPart.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
    count++;
  }
  final reversed = buffer.toString().split('').reversed.join();
  return 'R\$ $reversed,$decPart';
}
 
class HistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;
 
  const HistoryScreen({super.key, required this.transactions});
 
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
 
class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Todos'; // Todos | Gastos | Receitas
  String _searchQuery = '';
  final _searchController = TextEditingController();
 
  List<Transaction> get _filtered {
    return widget.transactions.where((t) {
      final matchType = _filter == 'Todos'
          ? true
          : _filter == 'Gastos'
              ? t.isExpense
              : !t.isExpense;
      final matchSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }
 
  // Group transactions by date label
  Map<String, List<Transaction>> get _grouped {
    final map = <String, List<Transaction>>{};
    for (final t in _filtered) {
      final label = _dateLabel(t.date);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map;
  }
 
  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDay = DateTime(d.year, d.month, d.day);
    if (txDay == today) return 'Hoje';
    if (txDay == yesterday) return 'Ontem';
    const months = [
      '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${d.day} de ${months[d.month]}';
  }
 
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final keys = grouped.keys.toList();
 
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context)),
 
          // ── Filter chips ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: ['Todos', 'Gastos', 'Receitas'].map((label) {
                  final active = _filter == label;
                  final color = label == 'Gastos'
                      ? AppColors.expense
                      : label == 'Receitas'
                          ? AppColors.income
                          : AppColors.primary;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? color : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? color : AppColors.border,
                          ),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : AppColors.textGray,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
 
          // ── Transaction groups ───────────────────────────────────
          if (keys.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma transação encontrada',
                        style: GoogleFonts.poppins(
                            color: AppColors.textGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final key = keys[index];
                    final items = grouped[key]!;
                    final dayTotal = items.fold<double>(
                      0,
                      (sum, t) => sum + (t.isExpense ? -t.amount : t.amount),
                    );
                    return _DayGroup(
                      label: key,
                      dayTotal: dayTotal,
                      transactions: items,
                    );
                  },
                  childCount: keys.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
 
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Histórico',
              style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('Todas as suas movimentações',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white60)),
          const SizedBox(height: 16),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar transação...',
                hintStyle:
                    GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGray),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.clear, color: AppColors.textGray),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _DayGroup extends StatelessWidget {
  final String label;
  final double dayTotal;
  final List<Transaction> transactions;
 
  const _DayGroup({
    required this.label,
    required this.dayTotal,
    required this.transactions,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray)),
            Text(
              '${dayTotal >= 0 ? '+' : ''}${_formatCurrency(dayTotal)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    dayTotal >= 0 ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...transactions.map((t) => _HistoryTile(transaction: t)),
      ],
    );
  }
}
 
class _HistoryTile extends StatelessWidget {
  final Transaction transaction;
 
  const _HistoryTile({required this.transaction});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: transaction.category.lightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(transaction.category.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                Text(
                  transaction.category.name +
                      (transaction.note != null
                          ? ' · ${transaction.note}'
                          : ''),
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textGray),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isExpense ? '-' : '+'}${_formatCurrency(transaction.amount)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: transaction.isExpense
                      ? AppColors.expense
                      : AppColors.income,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(transaction.date),
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}