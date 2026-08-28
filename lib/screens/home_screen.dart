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
 
const _monthNames = [
  '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];
 
class HomeScreen extends StatelessWidget {
  final List<Transaction> transactions;
 
  const HomeScreen({super.key, required this.transactions});
 
  double get _totalIncome =>
      transactions.where((t) => !t.isExpense).fold(0, (s, t) => s + t.amount);
 
  double get _totalExpense =>
      transactions.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);
 
  double get _balance => _totalIncome - _totalExpense;
 
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, now)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildSummaryRow(),
                const SizedBox(height: 24),
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildRecentSection(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildHeader(BuildContext context, DateTime now) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 32,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Olá, Sofia 👋',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                  Text('Grão 🌾',
                      style: GoogleFonts.poppins(
                          fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Saldo disponível',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white60)),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(_balance),
            style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text('${_monthNames[now.month]} ${now.year}',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54)),
        ],
      ),
    );
  }
 
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.arrow_upward_rounded,
            label: 'Receitas',
            value: _formatCurrency(_totalIncome),
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.arrow_downward_rounded,
            label: 'Gastos',
            value: _formatCurrency(_totalExpense),
            color: AppColors.expense,
          ),
        ),
      ],
    );
  }
 
  Widget _buildCategorySection() {
    final Map<String, double> totals = {};
    Category? catRef(String name) =>
        AppCategories.all.cast<Category?>().firstWhere(
          (c) => c!.name == name,
          orElse: () => null,
        );
 
    for (final t in transactions.where((t) => t.isExpense)) {
      totals[t.category.name] = (totals[t.category.name] ?? 0) + t.amount;
    }
    if (totals.isEmpty) return const SizedBox();
 
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gastos por categoria',
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        ...sorted.take(4).map((entry) {
          final cat = catRef(entry.key) ?? AppCategories.outros;
          final pct = _totalExpense > 0 ? entry.value / _totalExpense : 0.0;
          return _CategoryBar(
              category: cat, amount: entry.value, percentage: pct);
        }),
      ],
    );
  }
 
  Widget _buildRecentSection() {
    final recent = transactions.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recentes',
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nenhuma transação ainda.\nToque em + para adicionar!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.textGray),
              ),
            ),
          )
        else
          ...recent.map((t) => _TransactionTile(transaction: t)),
      ],
    );
  }
}
 
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
 
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textGray)),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
class _CategoryBar extends StatelessWidget {
  final Category category;
  final double amount;
  final double percentage;
 
  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.percentage,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Column(
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(category.name,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
              ),
              Text(_formatCurrency(amount),
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(category.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
 
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
 
  const _TransactionTile({required this.transaction});
 
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM').format(transaction.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                Text('${transaction.category.name} · $date',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textGray)),
              ],
            ),
          ),
          Text(
            '${transaction.isExpense ? '-' : '+'}${_formatCurrency(transaction.amount)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: transaction.isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }
}