import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../data/mock_repository.dart';
import '../data/repository.dart';
import '../models/goal.dart';
import '../models/transaction.dart';

/// Estado único do app. Quem precisa de dado pergunta aqui,
/// quem precisa gravar também — e ele fala com o repositório.
class AppState extends ChangeNotifier {
  AppState({
    required GraoRepository repository,
    required SharedPreferences prefs,
  })  : _repo = repository,
        _prefs = prefs {
    _name = prefs.getString(_kName) ?? '';
    _onboarded = prefs.getBool(_kOnboarded) ?? false;
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  static const _kName = 'user_name';
  static const _kOnboarded = 'onboarded';

  GraoRepository _repo;
  final SharedPreferences _prefs;

  String _name = '';
  bool _onboarded = false;
  bool _loading = true;
  bool _usingFallback = false;
  late DateTime _month;

  List<Transaction> _transactions = [];
  List<Goal> _goals = [];

  // ── Perfil ────────────────────────────────────────────────
  String get name => _name;
  bool get onboarded => _onboarded;

  Future<void> completeOnboarding(String name) async {
    _name = name.trim();
    _onboarded = true;
    await _prefs.setString(_kName, _name);
    await _prefs.setBool(_kOnboarded, true);
    notifyListeners();
  }

  Future<void> setName(String name) async {
    _name = name.trim();
    await _prefs.setString(_kName, _name);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _onboarded = false;
    await _prefs.setBool(_kOnboarded, false);
    notifyListeners();
  }

  // ── Fonte de dados ────────────────────────────────────────
  bool get loading => _loading;
  bool get isRemote => _repo.isRemote;
  bool get usingFallback => _usingFallback;
  String get sourceLabel => _repo.label;

  /// Carrega tudo. Se o banco remoto estiver vazio, popula com os dados de
  /// exemplo; se o banco falhar, cai para o mock e avisa na tela "Eu".
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      var txs = await _repo.fetchTransactions();
      var goals = await _repo.fetchGoals();
      if (_repo.isRemote && txs.isEmpty && goals.isEmpty) {
        await _seed();
        txs = await _repo.fetchTransactions();
        goals = await _repo.fetchGoals();
      }
      _transactions = txs;
      _goals = goals;
    } catch (e) {
      await _fallbackToLocal(e, keepCurrent: false);
    }
    _sort();
    _loading = false;
    notifyListeners();
  }

  Future<void> _seed() async {
    await _repo.addMany(MockData.transactions());
    for (final g in MockData.goals()) {
      await _repo.saveGoal(g);
    }
  }

  Future<void> _fallbackToLocal(Object error, {bool keepCurrent = true}) async {
    debugPrint('Banco indisponível, usando dados locais: $error');
    _usingFallback = true;
    if (keepCurrent) {
      _repo = MockRepository(
        transactions: List.of(_transactions),
        goals: List.of(_goals),
      );
    } else {
      _repo = MockRepository();
      _transactions = await _repo.fetchTransactions();
      _goals = await _repo.fetchGoals();
    }
  }

  void _sort() => _transactions.sort((a, b) => b.date.compareTo(a.date));

  /// Roda a operação no repositório; se falhar, troca para o mock e repete.
  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } catch (e) {
      await _fallbackToLocal(e);
      return await op();
    }
  }

  // ── Transações ────────────────────────────────────────────
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  Future<void> addTransaction(Transaction t) async {
    final saved = await _guard(() => _repo.addTransaction(t));
    _transactions.add(saved);
    _sort();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction t) async {
    await _guard(() => _repo.updateTransaction(t));
    final i = _transactions.indexWhere((x) => x.id == t.id);
    if (i >= 0) _transactions[i] = t;
    _sort();
    notifyListeners();
  }

  /// Remove na hora (a tela responde rápido) e confirma no banco depois.
  Future<void> deleteTransaction(Transaction t) async {
    _transactions.removeWhere((x) => x.id == t.id);
    notifyListeners();
    await _guard(() => _repo.deleteTransaction(t.id));
  }

  // ── Metas ─────────────────────────────────────────────────
  List<Goal> get goals => List.unmodifiable(_goals);

  Goal? goalFor(String categoryId) {
    for (final g in _goals) {
      if (g.categoryId == categoryId) return g;
    }
    return null;
  }

  Future<void> saveGoal(Goal goal) async {
    await _guard(() => _repo.saveGoal(goal));
    final i = _goals.indexWhere((g) => g.categoryId == goal.categoryId);
    if (i >= 0) {
      _goals[i] = goal;
    } else {
      _goals.add(goal);
    }
    notifyListeners();
  }

  Future<void> deleteGoal(String categoryId) async {
    await _guard(() => _repo.deleteGoal(categoryId));
    _goals.removeWhere((g) => g.categoryId == categoryId);
    notifyListeners();
  }

  /// Apaga tudo e volta para os dados de exemplo.
  Future<void> resetDemoData() async {
    await _guard(() async {
      await _repo.clearAll();
      await _seed();
    });
    _transactions = await _guard(() => _repo.fetchTransactions());
    _goals = await _guard(() => _repo.fetchGoals());
    _sort();
    notifyListeners();
  }

  // ── Mês selecionado ───────────────────────────────────────
  DateTime get month => _month;

  bool get canGoNext {
    final now = DateTime.now();
    return _month.isBefore(DateTime(now.year, now.month));
  }

  void previousMonth() {
    _month = DateTime(_month.year, _month.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    if (!canGoNext) return;
    _month = DateTime(_month.year, _month.month + 1);
    notifyListeners();
  }

  // ── Resumos do mês ────────────────────────────────────────
  List<Transaction> get monthTransactions => _transactions
      .where((t) => t.date.year == _month.year && t.date.month == _month.month)
      .toList();

  double get monthIncome => monthTransactions
      .where((t) => !t.isExpense)
      .fold<double>(0, (s, t) => s + t.amount);

  double get monthExpense => monthTransactions
      .where((t) => t.isExpense)
      .fold<double>(0, (s, t) => s + t.amount);

  double get monthBalance => monthIncome - monthExpense;

  /// Gasto do mês por categoria, do maior para o menor.
  List<MapEntry<String, double>> get monthExpenseRanking {
    final totals = <String, double>{};
    for (final t in monthTransactions.where((t) => t.isExpense)) {
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    }
    final list = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  double spentIn(String categoryId) {
    for (final e in monthExpenseRanking) {
      if (e.key == categoryId) return e.value;
    }
    return 0;
  }
}

/// Deixa o [AppState] acessível em qualquer tela.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  /// Dentro de `build`: a tela se reconstrói quando o estado muda.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado acima na árvore');
    return scope!.notifier!;
  }

  /// Em callbacks (onPressed etc.): lê sem se inscrever nas mudanças.
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado acima na árvore');
    return scope!.notifier!;
  }
}
