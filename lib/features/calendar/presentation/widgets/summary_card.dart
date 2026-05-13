import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';  // ← 추가
import '../../../../core/utils/format.dart';

class SummaryCard extends StatelessWidget {
  final int month;
  final int totalPrice;
  final int averageCalories;

  const SummaryCard({
    super.key,
    required this.month,
    required this.totalPrice,
    required this.averageCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _summaryItem(
            label: '$month월 총 비용',
            value: '₩${formatPrice(totalPrice)}',
          ),
        ),
        Container(
          width: 1,
          height: 36,
          color: AppColors.border,  // ← 변경
        ),
        Expanded(
          child: _summaryItem(
            label: '평균 칼로리',
            value: '${formatPrice(averageCalories)} kcal',
          ),
        ),
      ],
    );
  }

  Widget _summaryItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,  // ← 변경
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,  // ← 변경
          ),
        ),
      ],
    );
  }
}