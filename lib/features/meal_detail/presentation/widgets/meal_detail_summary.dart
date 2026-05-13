import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';

class MealDetailSummary extends StatelessWidget {
  final int totalPrice;
  final int totalCalories;

  const MealDetailSummary({
    super.key,
    required this.totalPrice,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 3.0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _item(label: '총 비용', value: '₩${formatPrice(totalPrice)}'),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _item(
              label: '총 칼로리',
              value: '${formatPrice(totalCalories)} kcal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}