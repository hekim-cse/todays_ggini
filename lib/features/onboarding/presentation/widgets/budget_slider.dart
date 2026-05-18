import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'image_thumb_shape.dart';

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
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.buttonGray,
            trackHeight: 6,
            thumbShape: ImageThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 100000,
            max: 1000000,
            divisions: 18,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '100',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
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