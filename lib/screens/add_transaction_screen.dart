import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
 
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});
 
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}
 
class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  Category _selectedCategory = AppCategories.alimentacao;
  final _titleController = TextEditingController();
  String _amountText = '0';
 
  void _tap(String key) {
    setState(() {
      if (key == '⌫') {
        _amountText = _amountText.length <= 1 ? '0' : _amountText.substring(0, _amountText.length - 1);
      } else if (key == ',') {
        if (!_amountText.contains(',')) _amountText += ',';
      } else {
        _amountText = _amountText == '0' ? key : _amountText + key;
      }
    });
  }
 
  void _save() {
    final amount = double.tryParse(_amountText.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite um valor maior que zero',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }
    final title = _titleController.text.trim().isEmpty
        ? _selectedCategory.name
        : _titleController.text.trim();
    Navigator.pop(
      context,
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        isExpense: _isExpense,
        category: _selectedCategory,
        date: DateTime.now(),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final isExpColor = _isExpense ? AppColors.expense : AppColors.income;
    final gradStart = _isExpense ? const Color(0xFFB91C1C) : const Color(0xFF059669);
 
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Nova transação',
            style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Salvar',
                style: GoogleFonts.poppins(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Área de valor ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradStart, isExpColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Toggle gasto/receita
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _ToggleBtn(
                          label: '💸  Gasto',
                          active: _isExpense,
                          activeColor: AppColors.expense,
                          onTap: () => setState(() {
                            _isExpense = true;
                            _selectedCategory = AppCategories.alimentacao;
                          }),
                        ),
                        _ToggleBtn(
                          label: '💰  Receita',
                          active: !_isExpense,
                          activeColor: AppColors.income,
                          onTap: () => setState(() {
                            _isExpense = false;
                            _selectedCategory = AppCategories.outros;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Valor
                  Text('R\$ $_amountText',
                      style: GoogleFonts.poppins(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1)),
                  const SizedBox(height: 20),
                  // Teclado numérico
                  _buildNumPad(),
                ],
              ),
            ),
 
            // ── Formulário ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Descrição (opcional)',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.edit_outlined,
                          color: AppColors.textGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
 
                  if (_isExpense) ...[
                    Text('Categoria',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.85,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: AppCategories.all.length,
                      itemBuilder: (_, i) {
                        final cat = AppCategories.all[i];
                        final sel = cat.name == _selectedCategory.name;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: sel ? cat.lightColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel ? cat.color : AppColors.border,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(cat.emoji,
                                    style: const TextStyle(fontSize: 22)),
                                const SizedBox(height: 4),
                                Text(cat.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: sel
                                          ? cat.color
                                          : AppColors.textGray,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
 
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text('Salvar transação',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
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
      children: rows.map((row) {
        return Row(
          children: row.map((k) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: GestureDetector(
                  onTap: () => _tap(k),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(k,
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
 
class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
 
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });
 
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
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: active ? activeColor : Colors.white)),
          ),
        ),
      ),
    );
  }
}