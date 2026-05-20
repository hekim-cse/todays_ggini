import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/widgets/thumb_slider.dart';

class MyPageBudgetSlider extends StatefulWidget {
  final int value;

  const MyPageBudgetSlider({
    super.key,
    required this.value,
  });

  @override
  State<MyPageBudgetSlider> createState() => _MyPageBudgetSliderState();
}

class _MyPageBudgetSliderState extends State<MyPageBudgetSlider> {
  ui.Image? _thumbImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load('assets/images/slider.png');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() => _thumbImage = frame.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('10', style: Theme.of(context).textTheme.bodySmall),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  disabledActiveTrackColor: AppColors.primary,
                  disabledInactiveTrackColor: AppColors.buttonGray,
                  disabledThumbColor: AppColors.primary,
                  trackHeight: 6,
                  thumbShape: ImageThumbShape(image: _thumbImage, showLabel: false),
                ),
                child: Slider(
                  value: widget.value.toDouble(),
                  min: 100000,
                  max: 1000000,
                  divisions: 18,
                  onChanged: null,
                ),
              ),
            ),
            Text('100', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: '${(widget.value / 10000).round()}',
                style: const TextStyle(color: AppColors.primary),
              ),
              const TextSpan(text: '만원 내에서 최적의 식단을 짜드려요!'),
            ],
          ),
        ),
      ],
    );
  }
}