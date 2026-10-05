import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../utils/format.dart';

/// "‹ Outubro 2026 ›" — troca o mês que as telas mostram.
class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Mês anterior',
          visualDensity: VisualDensity.compact,
          color: Colors.white,
          onPressed: state.previousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Text(
          monthYear(state.month),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          tooltip: 'Próximo mês',
          visualDensity: VisualDensity.compact,
          color: Colors.white,
          disabledColor: Colors.white30,
          onPressed: state.canGoNext ? state.nextMonth : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
