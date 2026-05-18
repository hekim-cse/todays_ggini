import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MenuVideoPlayer extends StatelessWidget {
  final String? videoUrl;

  const MenuVideoPlayer({super.key, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: videoUrl == null
              ? Text(
                  '영상 준비중',
                  style: Theme.of(context).textTheme.bodyMedium
                )
              : const Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: AppColors.primary,
                ),
        ),
      ),
    );
  }
}