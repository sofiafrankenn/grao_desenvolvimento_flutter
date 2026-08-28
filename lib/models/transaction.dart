import 'package:flutter/material.dart';
 
class Category {
  final String name;
  final String emoji;
  final Color color;
  final Color lightColor;
 
  const Category({
    required this.name,
    required this.emoji,
    required this.color,
    required this.lightColor,
  });
}
 
class AppCategories {
  static const Category alimentacao = Category(
    name: 'Alimentação', emoji: '🍔',
    color: Color(0xFFF59E0B), lightColor: Color(0xFFFEF3C7),
  );
  static const Category transporte = Category(
    name: 'Transporte', emoji: '🚌',
    color: Color(0xFF3B82F6), lightColor: Color(0xFFDBEAFE),
  );
  static const Category lazer = Category(
    name: 'Lazer', emoji: '🎮',
    color: Color(0xFF8B5CF6), lightColor: Color(0xFFEDE9FE),
  );
  static const Category estudos = Category(
    name: 'Estudos', emoji: '📚',
    color: Color(0xFF10B981), lightColor: Color(0xFFD1FAE5),
  );
  static const Category moradia = Category(
    name: 'Moradia', emoji: '🏠',
    color: Color(0xFFEF4444), lightColor: Color(0xFFFEE2E2),
  );
  static const Category saude = Category(
    name: 'Saúde', emoji: '💊',
    color: Color(0xFFEC4899), lightColor: Color(0xFFFCE7F3),
  );
  static const Category role = Category(
    name: 'Rolê', emoji: '🎉',
    color: Color(0xFFF97316), lightColor: Color(0xFFFFEDD5),
  );
  static const Category outros = Category(
    name: 'Outros', emoji: '📦',
    color: Color(0xFF6B7280), lightColor: Color(0xFFF3F4F6),
  );
 
  static const List<Category> all = [
    alimentacao, transporte, lazer, estudos,
    moradia, saude, role, outros,
  ];
}
 
class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final Category category;
  final DateTime date;
  final String? note;
 
  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
    this.note,
  });
}