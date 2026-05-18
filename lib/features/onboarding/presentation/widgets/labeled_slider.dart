import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'image_thumb_shape.dart';

class LabeledSlider extends StatelessWidget {
  final int value;
  final double min;
  final double max;
  final int divisions;
  final String Function(int) getLabel;
  final ValueChanged<int> onChanged;

  const LabeledSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.getLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = getLabel(value);
    return Column(
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
        ],
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
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              divisions + 1,
              (i) => Text(
                '${(min + i).toInt()}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
