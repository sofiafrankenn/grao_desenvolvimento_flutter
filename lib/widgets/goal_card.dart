import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/micro_copy.dart';

/// Cartão de meta: quanto já foi gasto numa categoria vs. o limite.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.onTap,
  });

  final Category category;
  final double spent;

  /// `null` = categoria sem meta definida.
  final double? limit;
  final VoidCallback? onTap;

  static Color colorForRatio(double ratio) {
    if (ratio > 1) return AppColors.expense;
    if (ratio >= 0.75) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = limit != null && limit! > 0;
    final ratio = hasGoal ? spent / limit! : 0.0;
    final color = hasGoal ? colorForRatio(ratio) : AppColors.textLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: category.lightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(category.icon, size: 20, color: category.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      hasGoal
                          ? '${formatMoney(spent)} de ${formatMoney(limit!)}'
                          : formatMoney(spent),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: hasGoal ? ratio.clamp(0.0, 1.0).toDouble() : 0,
                    minHeight: 7,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasGoal
                      ? MicroCopy.goalStatus(spent, limit!)
                      : 'Sem meta ainda. Toque pra definir um limite.',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasGoal ? color : AppColors.textGray,
                    fontWeight: hasGoal ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
