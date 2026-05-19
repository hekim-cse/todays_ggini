import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'thumb_slider.dart';


class DiversitySlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const DiversitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _getLabel(int v) {
    if (v == 1) return '한 가지 음식만 먹어도 괜찮아요';
    if (v == 2) return '적당히 다양하게 먹고 싶어요';
    return '매일 다른 음식을 먹고 싶어요';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('1', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            Expanded(
              child: ThumbSlider(
                value: value.toDouble(),
                min: 1,
                max: 3,
                divisions: 2,
                label: '$value',
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Text('3', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_getLabel(value)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}