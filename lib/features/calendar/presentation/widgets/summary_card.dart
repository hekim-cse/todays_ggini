import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
            context: context,
            label: '$month월 총 비용',
            value: '₩${formatPrice(totalPrice)}',
          ),
        ),
        Container(width: 3, height: 60, color: AppColors.border),
        Expanded(
          child: _summaryItem(
            context: context,
            label: '평균 칼로리',
            value: '${formatPrice(averageCalories)} kcal',
          ),
        ),
      ],
    );
  }

  Widget _summaryItem({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
