import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';  // ← 추가

class MonthHeader extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const MonthHeader({
    super.key,
    required this.year,
    required this.month,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textPrimary,  // ← 변경
            onPressed: onPrevMonth,
          ),
          const SizedBox(width: 100),
          Text(
            '$year · $month월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,  // ← 변경
            ),
          ),
          const SizedBox(width: 100),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textPrimary,  // ← 변경
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}