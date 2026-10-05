import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/category_chip.dart';

/// Tela de anotar gasto/entrada. Se receber [existing], vira edição.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.existing});

  final Transaction? existing;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late bool _isExpense;
  late Category _category;
  late DateTime _date;
  late String _amountText;
  final _titleController = TextEditingController();
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _isExpense = e.isExpense;
      _category = e.category;
      _date = e.date;
      _amountText = _toAmountText(e.amount);
      _titleController.text = e.title;
    } else {
      _isExpense = true;
      _category = AppCategories.alimentacao;
      _date = DateTime.now();
      _amountText = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _toAmountText(double v) {
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    return s.endsWith(',00') ? s.substring(0, s.length - 3) : s;
  }

  double get _amount {
    final raw = _amountText.endsWith(',')
        ? _amountText.substring(0, _amountText.length - 1)
        : _amountText;
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }

  void _tap(String key) {
    setState(() {
      if (key == '⌫') {
        _amountText = _amountText.length <= 1
            ? '0'
            : _amountText.substring(0, _amountText.length - 1);
        return;
      }
      if (key == ',') {
        if (!_amountText.contains(',')) _amountText += ',';
        return;
      }
      final comma = _amountText.indexOf(',');
      if (comma != -1 && _amountText.length - comma - 1 >= 2) return;
      if (_amountText.replaceAll(',', '').length >= 8) return;
      _amountText = _amountText == '0' ? key : _amountText + key;
    });
  }

  void _setType(bool expense) {
    if (expense == _isExpense) return;
    setState(() {
      _isExpense = expense;
      _category = expense ? AppCategories.alimentacao : AppCategories.mesada;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Quando foi?',
      cancelText: 'Cancelar',
      confirmText: 'Escolher',
    );
    if (picked == null) return;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_amount <= 0) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Coloca um valor primeiro.')),
        );
      return;
    }

    final state = AppScope.read(context);
    final nav = Navigator.of(context);
    final typed = _titleController.text.trim();
    final title = typed.isEmpty ? _category.name : typed;
    final existing = widget.existing;
    final wasExpense = _isExpense;

    setState(() => _saving = true);

    if (existing == null) {
      await state.addTransaction(
        Transaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          amount: _amount,
          isExpense: _isExpense,
          categoryId: _category.id,
          date: _date,
        ),
      );
    } else {
      await state.updateTransaction(
        existing.copyWith(
          title: title,
          amount: _amount,
          isExpense: _isExpense,
          categoryId: _category.id,
          date: _date,
        ),
      );
    }

    nav.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            existing != null
                ? 'Alterações salvas.'
                : (wasExpense ? 'Gasto anotado.' : 'Entrada anotada.'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _isExpense ? AppCategories.expenses : AppCategories.incomes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          _editing ? 'Editar anotação' : 'Nova anotação',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fechar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Valor ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(46),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _ToggleBtn(
                          label: 'Gastei',
                          active: _isExpense,
                          activeColor: AppColors.expense,
                          onTap: () => _setType(true),
                        ),
                        _ToggleBtn(
                          label: 'Recebi',
                          active: !_isExpense,
                          activeColor: AppColors.income,
                          onTap: () => _setType(false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'R\$ $_amountText',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNumPad(),
                ],
              ),
            ),

            // ── Detalhes ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: _isExpense
                          ? 'Do que foi? (ex: bandejão)'
                          : 'De onde veio? (ex: freela)',
                      prefixIcon: const Icon(Icons.edit_outlined,
                          color: AppColors.textGray),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 20, color: AppColors.textGray),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dayLabel(_date) == 'Hoje' ||
                                        dayLabel(_date) == 'Ontem'
                                    ? dayLabel(_date)
                                    : longDate(_date),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const Text(
                              'trocar',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Categoria',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    childAspectRatio: 0.9,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      for (final c in categories)
                        CategoryChip(
                          category: c,
                          selected: c.id == _category.id,
                          onTap: () => setState(() => _category = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(
                          _editing ? 'Salvar alterações' : 'Salvar anotação'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    const rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      [',', '0', '⌫'],
    ];
    return Column(
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final k in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _tap(k),
                        child: SizedBox(
                          height: 50,
                          child: Center(
                            child: k == '⌫'
                                ? const Icon(Icons.backspace_outlined,
                                    color: Colors.white, size: 22)
                                : Text(
                                    k,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active ? activeColor : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
