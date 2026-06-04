import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'thumb_slider.dart';

class BudgetSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const BudgetSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('10', style: Theme.of(context).textTheme.bodySmall),
            Expanded(
              child: ThumbSlider(
                value: value.toDouble(),
                min: 100000,
                max: 1000000,
                divisions: 18,
                label: '${(value / 10000).round()}',
                showThumbLabel: false,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Text('100', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '${(value / 10000).round()}',
                  style: const TextStyle(color: AppColors.primary),
                ),
                const TextSpan(text: '만원 내에서 최적의 식단을 짜드려요!'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}