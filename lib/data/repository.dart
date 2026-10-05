import '../models/goal.dart';
import '../models/transaction.dart';

/// Contrato de acesso a dados. O app só conhece essa interface:
/// quem implementa decide se os dados vêm do Supabase ou do mock.
abstract class GraoRepository {
  /// Nome amigável da fonte de dados (aparece na tela "Eu").
  String get label;

  /// `true` quando os dados ficam fora do aparelho (Supabase).
  bool get isRemote;

  Future<List<Transaction>> fetchTransactions();
  Future<Transaction> addTransaction(Transaction t);
  Future<void> addMany(List<Transaction> list);
  Future<void> updateTransaction(Transaction t);
  Future<void> deleteTransaction(String id);

  Future<List<Goal>> fetchGoals();
  Future<void> saveGoal(Goal goal);
  Future<void> deleteGoal(String categoryId);

  /// Apaga tudo (usado em "Restaurar dados de exemplo").
  Future<void> clearAll();
}
