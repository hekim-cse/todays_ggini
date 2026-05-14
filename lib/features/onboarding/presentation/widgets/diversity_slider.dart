import 'package:flutter/material.dart';
import 'dart:ui' as ui;
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

  String _getLabel(int v) {
    if (v == 1) return '한 가지 음식만 먹어도 괜찮아요';
    if (v == 2) return '적당히 다양하게 먹고 싶어요';
    return '매일 다른 음식을 먹고 싶어요';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _getLabel(value),
          style: const TextStyle(fontSize: 13, color: AppColors.textHint),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDim,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1', style: TextStyle(color: AppColors.textHint)),
              Text('2', style: TextStyle(color: AppColors.textHint)),
              Text('3', style: TextStyle(color: AppColors.textHint)),
            ],
          ),
        ),
      ],
    );
  }
}