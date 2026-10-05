import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../screens/add_transaction_screen.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

/// Detalhe de uma anotação, com atalhos para editar e excluir.
Future<void> showTransactionSheet(BuildContext context, Transaction t) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TransactionSheet(transaction: t),
  );
}

/// Exclui e oferece "Desfazer" — mais rápido que pedir confirmação.
void deleteWithUndo(BuildContext context, Transaction t) {
  deleteWithUndoUsing(
    AppScope.read(context),
    ScaffoldMessenger.of(context),
    t,
  );
}

/// Versão que não depende de um `context` ainda vivo (útil depois de fechar
/// um bottom sheet).
void deleteWithUndoUsing(
  AppState state,
  ScaffoldMessengerState messenger,
  Transaction t,
) {
  state.deleteTransaction(t);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('"${t.title}" foi excluída'),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: AppColors.primaryLight,
          onPressed: () => state.addTransaction(t),
        ),
      ),
    );
}

class _TransactionSheet extends StatelessWidget {
  const _TransactionSheet({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final cat = t.category;
    final color = t.isExpense ? AppColors.expense : AppColors.income;
    final hasNote = t.note != null && t.note!.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cat.lightColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(cat.icon, color: cat.color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              t.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(cat.name, style: const TextStyle(color: AppColors.textGray)),
            const SizedBox(height: 10),
            Text(
              '${t.isExpense ? '-' : '+'}${formatMoney(t.amount)}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Quando',
              value: '${longDate(t.date)}, ${timeLabel(t.date)}',
            ),
            _InfoRow(label: 'Tipo', value: t.isExpense ? 'Gasto' : 'Entrada'),
            if (hasNote) _InfoRow(label: 'Obs.', value: t.note!),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.expense,
                      side: const BorderSide(color: AppColors.expense),
                    ),
                    onPressed: () {
                      final state = AppScope.read(context);
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.of(context).pop();
                      deleteWithUndoUsing(state, messenger, t);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    label: const Text('Excluir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final nav = Navigator.of(context);
                      nav.pop();
                      nav.push(
                        MaterialPageRoute<void>(
                          fullscreenDialog: true,
                          builder: (_) => AddTransactionScreen(existing: t),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(color: AppColors.textGray)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
