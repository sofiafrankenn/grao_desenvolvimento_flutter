import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
 
void main() {
  runApp(const GraoApp());
}
 
class GraoApp extends StatefulWidget {
  const GraoApp({super.key});
 
  @override
  State<GraoApp> createState() => _GraoAppState();
}
 
class _GraoAppState extends State<GraoApp> {
  final List<Transaction> _transactions = [
    Transaction(
      id: '1', title: 'iFood', amount: 35.90, isExpense: true,
      category: AppCategories.alimentacao,
      date: DateTime.now(),
    ),
    Transaction(
      id: '2', title: 'Bilhete único', amount: 20.00, isExpense: true,
      category: AppCategories.transporte,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: '3', title: 'Mesada', amount: 800.00, isExpense: false,
      category: AppCategories.outros,
      date: DateTime.now().subtract(const Duration(days: 2)),
      note: 'Agosto 2026',
    ),
    Transaction(
      id: '4', title: 'Livro Flutter', amount: 89.00, isExpense: true,
      category: AppCategories.estudos,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: '5', title: 'Estágio', amount: 1200.00, isExpense: false,
      category: AppCategories.outros,
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: 'Agosto/2026',
    ),
    Transaction(
      id: '6', title: 'Cinema', amount: 42.00, isExpense: true,
      category: AppCategories.role,
      date: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Transaction(
      id: '7', title: 'Farmácia', amount: 28.50, isExpense: true,
      category: AppCategories.saude,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
 
  void _addTransaction(Transaction t) {
    setState(() => _transactions.insert(0, t));
  }
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grão',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: MainShell(
        transactions: _transactions,
        onAddTransaction: _addTransaction,
      ),
    );
  }
}
 
class MainShell extends StatefulWidget {
  final List<Transaction> transactions;
  final void Function(Transaction) onAddTransaction;
 
  const MainShell({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
  });
 
  @override
  State<MainShell> createState() => _MainShellState();
}
 
class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
 
  Future<void> _openAddScreen() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (result != null) widget.onAddTransaction(result);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? HomeScreen(transactions: widget.transactions)
          : HistoryScreen(transactions: widget.transactions),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: 'Histórico',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddScreen,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}