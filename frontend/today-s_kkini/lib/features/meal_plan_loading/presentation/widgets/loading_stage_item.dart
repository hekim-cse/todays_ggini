import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LoadingStageItem extends StatelessWidget {
  final String label;
  final bool isDone;

  const LoadingStageItem({
    super.key,
    required this.label,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.textPrimary : Colors.transparent,
              border: Border.all(
                color: isDone ? AppColors.textPrimary : AppColors.border,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDone ? AppColors.textPrimary : AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}
