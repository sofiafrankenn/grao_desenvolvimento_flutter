import '../models/goal.dart';
import '../models/transaction.dart';
import 'mock_data.dart';
import 'repository.dart';

/// Repositório em memória. É o que roda sem internet, sem chaves e nos testes.
class MockRepository implements GraoRepository {
  MockRepository({List<Transaction>? transactions, List<Goal>? goals})
      : _transactions = List.of(transactions ?? MockData.transactions()),
        _goals = List.of(goals ?? MockData.goals());

  final List<Transaction> _transactions;
  final List<Goal> _goals;

  @override
  String get label => 'Dados de exemplo';

  @override
  bool get isRemote => false;

  @override
  Future<List<Transaction>> fetchTransactions() async =>
      List.of(_transactions);

  @override
  Future<Transaction> addTransaction(Transaction t) async {
    _transactions.add(t);
    return t;
  }

  @override
  Future<void> addMany(List<Transaction> list) async {
    _transactions.addAll(list);
  }

  @override
  Future<void> updateTransaction(Transaction t) async {
    final i = _transactions.indexWhere((x) => x.id == t.id);
    if (i >= 0) _transactions[i] = t;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((x) => x.id == id);
  }

  @override
  Future<List<Goal>> fetchGoals() async => List.of(_goals);

  @override
  Future<void> saveGoal(Goal goal) async {
    final i = _goals.indexWhere((g) => g.categoryId == goal.categoryId);
    if (i >= 0) {
      _goals[i] = goal;
    } else {
      _goals.add(goal);
    }
  }

  @override
  Future<void> deleteGoal(String categoryId) async {
    _goals.removeWhere((g) => g.categoryId == categoryId);
  }

  @override
  Future<void> clearAll() async {
    _transactions.clear();
    _goals.clear();
  }
}
