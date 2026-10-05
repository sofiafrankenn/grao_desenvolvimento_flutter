import 'category.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String categoryId;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.categoryId,
    required this.date,
    this.note,
  });

  Category get category => AppCategories.byId(categoryId);

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isExpense,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  /// Formato da tabela `transactions` do Supabase.
  Map<String, dynamic> toMap({bool withId = true}) {
    return {
      if (withId) 'id': id,
      'title': title,
      'amount': amount,
      'is_expense': isExpense,
      'category': categoryId,
      'date': date.toUtc().toIso8601String(),
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'].toString(),
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      isExpense: map['is_expense'] as bool,
      categoryId: map['category'] as String,
      date: DateTime.parse(map['date'] as String).toLocal(),
      note: map['note'] as String?,
    );
  }
}
