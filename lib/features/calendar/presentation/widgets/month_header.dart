import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
            color: AppColors.textPrimary,
            iconSize: 32,
            onPressed: onPrevMonth,
          ),
          const Spacer(),
          Text(
            '$year년 $month월',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textPrimary,
            iconSize: 32,
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}
