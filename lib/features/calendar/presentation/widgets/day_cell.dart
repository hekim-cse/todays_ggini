import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';  // ← 추가
import '../../domain/monthly_meal_plan.dart';
import '../../../../core/utils/format.dart';

class DayCell extends StatelessWidget {
  final DayEntry? day;
  final VoidCallback? onTap;

  const DayCell({super.key, this.day, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: AppColors.border, width: 1),  // ← 변경
            bottom: BorderSide(color: AppColors.border, width: 1),  // ← 변경
          ),
        ),
      );
    }

    final hasPlan = day!.hasMealPlan;

    return InkWell(
      onTap: hasPlan ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: AppColors.border, width: 1),  // ← 변경
            bottom: BorderSide(color: AppColors.border, width: 1),  // ← 변경
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '${day!.date.day}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: hasPlan
                    ? AppColors.textPrimary  // ← 변경
                    : AppColors.border,      // ← 변경
              ),
            ),
            if (hasPlan) Expanded(child: _buildPlanInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfo() {
    final meals = day!.meals;
    final visibleMeals = meals.take(2).toList();
    final hasMore = meals.length > 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        ...visibleMeals.map(
          (m) => Text(
            '식단${m.slot}:${m.menuName}',
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.textPrimary,  // ← 변경
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasMore)
          const Text(
            '...',
            style: TextStyle(
              fontSize: 8,
              color: AppColors.textPrimary,  // ← 변경
            ),
          ),
        const Spacer(),
        if (day!.caloriesPerDay != null)
          Text(
            '${formatPrice(day!.caloriesPerDay!)}kcal',
            style: const TextStyle(
              fontSize: 7,
              color: AppColors.textPrimary,  // ← 변경
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (day!.pricePerDay != null)
          Text(
            '₩${formatPrice(day!.pricePerDay!)}',
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,  // ← 변경
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}