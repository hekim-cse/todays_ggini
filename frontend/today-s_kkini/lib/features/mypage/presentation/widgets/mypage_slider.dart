import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/widgets/thumb_slider.dart';

class MyPageSlider extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final String label;

  const MyPageSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
  });

  @override
  State<MyPageSlider> createState() => _MyPageSliderState();
}

class _MyPageSliderState extends State<MyPageSlider> {
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
            Text('${widget.min}', style: Theme.of(context).textTheme.bodySmall),
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
                  min: widget.min.toDouble(),
                  max: widget.max.toDouble(),
                  divisions: widget.max - widget.min,
                  onChanged: null,
                ),
              ),
            ),
            Text('${widget.max}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        if (widget.label.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${widget.label}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}