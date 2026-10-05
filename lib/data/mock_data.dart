import '../models/category.dart';
import '../models/goal.dart';
import '../models/transaction.dart';

/// Dados de exemplo com cara de vida real de estudante.
///
/// As datas são calculadas a partir de "hoje", então o app sempre tem
/// movimentação no mês atual, no mês passado e retrasado — sem ficar
/// com data velha na apresentação.
///
/// Casos cobertos de propósito:
///  • mês atual com saldo positivo e todas as metas no verde;
///  • mês passado com meta estourada (Rolê) e meta quase no limite (Transporte);
///  • dois meses atrás fechando no vermelho (gasto > entrada);
///  • valores pequenos (R$ 4,50), grandes (R$ 1.450,00) e com centavos;
///  • entradas de tipos diferentes (mesada, estágio, bolsa, extra).
class MockData {
  static DateTime _at(
    DateTime now,
    int monthsAgo,
    int day,
    int hour,
    int minute,
  ) {
    final first = DateTime(now.year, now.month - monthsAgo, 1);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    var d = day > lastDay ? lastDay : day;
    if (monthsAgo == 0 && d > now.day) d = now.day;
    var result = DateTime(first.year, first.month, d, hour, minute);
    if (result.isAfter(now)) {
      result = now.subtract(Duration(minutes: 10 + day));
    }
    return result;
  }

  static List<Transaction> transactions([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    var n = 0;

    Transaction t(
      String title,
      double amount,
      Category category,
      int monthsAgo,
      int day, {
      int hour = 12,
      int minute = 0,
      String? note,
    }) {
      n++;
      return Transaction(
        id: 'mock-$n',
        title: title,
        amount: amount,
        isExpense: !category.isIncome,
        categoryId: category.id,
        date: _at(now, monthsAgo, day, hour, minute),
        note: note,
      );
    }

    final list = <Transaction>[
      // ── Mês atual ────────────────────────────────────────
      t('Mesada', 800.00, AppCategories.mesada, 0, 1, hour: 8),
      t('Pagamento do estágio', 1450.00, AppCategories.estagio, 0, 5, hour: 9),
      t('Rateio da república', 520.00, AppCategories.moradia, 0, 3, hour: 10),
      t('Mercado', 87.30, AppCategories.alimentacao, 0, 2, hour: 18, minute: 40),
      t('Bandejão', 14.50, AppCategories.alimentacao, 0, 2, hour: 12, minute: 15),
      t('iFood', 38.90, AppCategories.alimentacao, 0, 4, hour: 20, minute: 5),
      t('Café', 4.50, AppCategories.alimentacao, 0, 4, hour: 15, minute: 30),
      t('Recarga do bilhete único', 50.00, AppCategories.transporte, 0, 3, hour: 7, minute: 50),
      t('Uber pra faculdade', 22.40, AppCategories.transporte, 0, 6, hour: 7, minute: 20, note: 'Choveu'),
      t('Cinema', 36.00, AppCategories.lazer, 0, 7, hour: 19, minute: 30),
      t('Spotify estudante', 11.90, AppCategories.lazer, 0, 8, hour: 6),
      t('Bar com a galera', 74.00, AppCategories.role, 0, 6, hour: 22, minute: 10),
      t('Xerox e apostila', 18.50, AppCategories.estudos, 0, 4, hour: 11, minute: 25),
      t('Livro de Flutter', 89.90, AppCategories.estudos, 0, 5, hour: 14),
      t('Farmácia', 28.50, AppCategories.saude, 0, 7, hour: 17, minute: 45),
      t('Freela de site', 300.00, AppCategories.extra, 0, 9, hour: 16, note: 'Site de uma loja de bairro'),

      // ── Mês passado ──────────────────────────────────────
      t('Mesada', 800.00, AppCategories.mesada, 1, 1, hour: 8),
      t('Pagamento do estágio', 1450.00, AppCategories.estagio, 1, 5, hour: 9),
      t('Bolsa de monitoria', 400.00, AppCategories.bolsa, 1, 10, hour: 9, minute: 30),
      t('Rateio da república', 520.00, AppCategories.moradia, 1, 3, hour: 10),
      t('Mercado do mês', 142.80, AppCategories.alimentacao, 1, 6, hour: 18),
      t('Mercado', 96.10, AppCategories.alimentacao, 1, 20, hour: 19),
      t('Bandejão', 14.50, AppCategories.alimentacao, 1, 8, hour: 12, minute: 10),
      t('Bandejão', 14.50, AppCategories.alimentacao, 1, 9, hour: 12, minute: 20),
      t('Bandejão', 14.50, AppCategories.alimentacao, 1, 15, hour: 12, minute: 5),
      t('iFood', 45.90, AppCategories.alimentacao, 1, 12, hour: 21),
      t('iFood', 39.90, AppCategories.alimentacao, 1, 25, hour: 20, minute: 40),
      t('Recarga do bilhete único', 50.00, AppCategories.transporte, 1, 3, hour: 7, minute: 45),
      t('Recarga do bilhete único', 50.00, AppCategories.transporte, 1, 17, hour: 7, minute: 40),
      t('Uber', 31.20, AppCategories.transporte, 1, 14, hour: 23, minute: 5),
      t('Uber', 18.90, AppCategories.transporte, 1, 22, hour: 8),
      t('Cinema', 36.00, AppCategories.lazer, 1, 11, hour: 19, minute: 45),
      t('Spotify estudante', 11.90, AppCategories.lazer, 1, 8, hour: 6),
      t('Jogo na Steam', 59.90, AppCategories.lazer, 1, 18, hour: 22),
      t('Show', 120.00, AppCategories.role, 1, 19, hour: 21, note: 'Ingresso meia'),
      t('Bar', 88.00, AppCategories.role, 1, 26, hour: 22, minute: 30),
      t('Churrasco da turma', 45.00, AppCategories.role, 1, 28, hour: 14),
      t('Apostila', 35.00, AppCategories.estudos, 1, 4, hour: 11),
      t('Caneta e caderno', 27.90, AppCategories.estudos, 1, 4, hour: 11, minute: 30),
      t('Dentista', 90.00, AppCategories.saude, 1, 13, hour: 15),
      t('Presente de aniversário', 55.00, AppCategories.outros, 1, 21, hour: 13),

      // ── Dois meses atrás (fechou no vermelho) ────────────
      t('Mesada', 800.00, AppCategories.mesada, 2, 1, hour: 8),
      t('Rateio da república', 520.00, AppCategories.moradia, 2, 3, hour: 10),
      t('Mercado', 160.00, AppCategories.alimentacao, 2, 7, hour: 18),
      t('iFood', 70.00, AppCategories.alimentacao, 2, 15, hour: 21),
      t('Uber', 45.00, AppCategories.transporte, 2, 12, hour: 22),
      t('Festa de calouros', 180.00, AppCategories.role, 2, 20, hour: 23),
      t('Cinema', 40.00, AppCategories.lazer, 2, 9, hour: 19),
      t('Farmácia', 35.00, AppCategories.saude, 2, 18, hour: 16),
      t('Conserto do notebook', 240.00, AppCategories.outros, 2, 24, hour: 14, note: 'Trocou a tela'),
    ];

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static List<Goal> goals() => const [
        Goal(categoryId: 'alimentacao', limit: 450),
        Goal(categoryId: 'transporte', limit: 180),
        Goal(categoryId: 'role', limit: 150),
        Goal(categoryId: 'lazer', limit: 100),
        Goal(categoryId: 'estudos', limit: 200),
        Goal(categoryId: 'moradia', limit: 550),
      ];
}
