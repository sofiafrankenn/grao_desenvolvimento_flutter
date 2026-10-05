import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final bool isIncome;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.lightColor,
    this.isIncome = false,
  });
}

class AppCategories {
  // ── Gastos ────────────────────────────────────────────────
  static const Category alimentacao = Category(
    id: 'alimentacao',
    name: 'Alimentação',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFF59E0B),
    lightColor: Color(0xFFFEF3C7),
  );
  static const Category transporte = Category(
    id: 'transporte',
    name: 'Transporte',
    icon: Icons.directions_bus_rounded,
    color: Color(0xFF3B82F6),
    lightColor: Color(0xFFDBEAFE),
  );
  static const Category lazer = Category(
    id: 'lazer',
    name: 'Lazer',
    icon: Icons.sports_esports_rounded,
    color: Color(0xFF8B5CF6),
    lightColor: Color(0xFFEDE9FE),
  );
  static const Category estudos = Category(
    id: 'estudos',
    name: 'Estudos',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF10B981),
    lightColor: Color(0xFFD1FAE5),
  );
  static const Category moradia = Category(
    id: 'moradia',
    name: 'Moradia',
    icon: Icons.home_rounded,
    color: Color(0xFFEF4444),
    lightColor: Color(0xFFFEE2E2),
  );
  static const Category saude = Category(
    id: 'saude',
    name: 'Saúde',
    icon: Icons.favorite_rounded,
    color: Color(0xFFEC4899),
    lightColor: Color(0xFFFCE7F3),
  );
  static const Category role = Category(
    id: 'role',
    name: 'Rolê',
    icon: Icons.celebration_rounded,
    color: Color(0xFFF97316),
    lightColor: Color(0xFFFFEDD5),
  );
  static const Category outros = Category(
    id: 'outros',
    name: 'Outros',
    icon: Icons.category_rounded,
    color: Color(0xFF6B7280),
    lightColor: Color(0xFFF3F4F6),
  );

  // ── Entradas ──────────────────────────────────────────────
  static const Category mesada = Category(
    id: 'mesada',
    name: 'Mesada',
    icon: Icons.savings_rounded,
    color: Color(0xFF10B981),
    lightColor: Color(0xFFD1FAE5),
    isIncome: true,
  );
  static const Category estagio = Category(
    id: 'estagio',
    name: 'Estágio',
    icon: Icons.work_rounded,
    color: Color(0xFF059669),
    lightColor: Color(0xFFD1FAE5),
    isIncome: true,
  );
  static const Category bolsa = Category(
    id: 'bolsa',
    name: 'Bolsa',
    icon: Icons.school_rounded,
    color: Color(0xFF0D9488),
    lightColor: Color(0xFFCCFBF1),
    isIncome: true,
  );
  static const Category extra = Category(
    id: 'extra',
    name: 'Extra',
    icon: Icons.bolt_rounded,
    color: Color(0xFF16A34A),
    lightColor: Color(0xFFDCFCE7),
    isIncome: true,
  );

  static const List<Category> expenses = [
    alimentacao,
    transporte,
    lazer,
    estudos,
    moradia,
    saude,
    role,
    outros,
  ];

  static const List<Category> incomes = [mesada, estagio, bolsa, extra];

  static const List<Category> all = [...expenses, ...incomes];

  static Category byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => outros);
}
