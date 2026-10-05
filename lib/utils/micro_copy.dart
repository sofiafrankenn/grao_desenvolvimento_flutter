import '../models/category.dart';
import '../state/app_state.dart';
import 'format.dart';

/// Frases do app, num lugar só — fica fácil manter o tom de voz do CP4:
/// papo de amigo que entende de grana, sem julgar e sem jargão.
class MicroCopy {
  /// Linha curta embaixo da saudação na tela inicial.
  static String homeSummary(AppState s) {
    final expense = s.monthExpense;
    final income = s.monthIncome;
    final balance = s.monthBalance;

    if (s.monthTransactions.isEmpty) {
      return 'Esse mês ainda tá zerado. Anota o primeiro quando rolar.';
    }
    if (balance < 0) {
      return 'Esse mês saiu mais do que entrou. Dá uma olhada no gráfico pra ver onde apertar.';
    }
    if (income > 0 && expense / income >= 0.85) {
      return 'Já foi mais de 85% do que entrou. Vale segurar um pouco.';
    }
    if (expense == 0) {
      return 'Nenhum gasto anotado ainda. Que calmaria.';
    }
    return 'Tá sobrando ${formatMoney(balance)} por enquanto.';
  }

  /// Frase que acompanha o gráfico de categorias.
  static String chartInsight(AppState s) {
    final ranking = s.monthExpenseRanking;
    if (ranking.isEmpty || s.monthExpense <= 0) return '';
    final top = ranking.first;
    final pct = (top.value / s.monthExpense * 100).round();
    final name = AppCategories.byId(top.key).name;
    return 'A maior fatia foi $name: $pct% do que você gastou.';
  }

  /// Resumo da tela de metas.
  static String goalsSummary(int ok, int total) {
    if (total == 0) {
      return 'Escolha um limite pra categoria e o Grão te avisa antes de estourar.';
    }
    if (ok == total) {
      return total == 1
          ? 'Sua meta tá no verde esse mês.'
          : 'Todas as $total metas estão no verde esse mês.';
    }
    return '$ok de $total metas no verde esse mês.';
  }

  /// Frase de status de uma meta.
  static String goalStatus(double spent, double limit) {
    if (spent > limit) {
      return 'Passou ${formatMoney(spent - limit)} do limite';
    }
    if (spent == limit) return 'Bateu o limite certinho';
    return 'Ainda dá pra gastar ${formatMoney(limit - spent)}';
  }
}
