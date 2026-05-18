import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'image_thumb_shape.dart';

class DiversitySlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const DiversitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  // diversity int → String 변환
  String diversityToString(int value) {
    if (value == 1) return '낮음';
    if (value == 2) return '보통';
    return '높음';
  }

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
            Text(
              '1',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.buttonGray,
                  trackHeight: 6,
                  thumbShape: ImageThumbShape(),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            Text(
              '3',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$value: ${_getLabel(value)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
