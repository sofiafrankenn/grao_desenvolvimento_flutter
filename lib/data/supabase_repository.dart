import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../models/goal.dart';
import '../models/transaction.dart';
import 'repository.dart';

/// Repositório ligado ao Supabase.
/// As tabelas estão em `supabase/schema.sql`.
class SupabaseRepository implements GraoRepository {
  final _db = Supabase.instance.client;

  static const _tx = 'transactions';
  static const _goals = 'goals';

  @override
  String get label => 'Supabase';

  @override
  bool get isRemote => true;

  @override
  Future<List<Transaction>> fetchTransactions() async {
    final rows = await _db.from(_tx).select().order('date', ascending: false);
    return rows.map<Transaction>((r) => Transaction.fromMap(r)).toList();
  }

  @override
  Future<Transaction> addTransaction(Transaction t) async {
    final row =
        await _db.from(_tx).insert(t.toMap(withId: false)).select().single();
    return Transaction.fromMap(row);
  }

  @override
  Future<void> addMany(List<Transaction> list) async {
    if (list.isEmpty) return;
    await _db
        .from(_tx)
        .insert(list.map((t) => t.toMap(withId: false)).toList());
  }

  @override
  Future<void> updateTransaction(Transaction t) async {
    await _db.from(_tx).update(t.toMap(withId: false)).eq('id', t.id);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.from(_tx).delete().eq('id', id);
  }

  @override
  Future<List<Goal>> fetchGoals() async {
    final rows = await _db.from(_goals).select();
    return rows.map<Goal>((r) => Goal.fromMap(r)).toList();
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    await _db.from(_goals).upsert(goal.toMap());
  }

  @override
  Future<void> deleteGoal(String categoryId) async {
    await _db.from(_goals).delete().eq('category', categoryId);
  }

  @override
  Future<void> clearAll() async {
    await _db.from(_tx).delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await _db.from(_goals).delete().neq('category', '');
  }
}
