import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/meal_style.dart';

Color _getBarColor(int value) {
  if (value <= 3) return Colors.red;
  if (value <= 6) return Colors.green;
  return Colors.blue;
}

class MealStyleCard extends StatelessWidget {
  final MealStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const MealStyleCard({
    super.key,
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mypage : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceDim,
            width: 2.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                style.tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3일치 샘플 식단',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...style.meals.map((meal) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Text('🍽️', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  meal,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 4),
                      Text(
                        style.desc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: style.stats.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: e.value * 8.0,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getBarColor(e.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${e.value}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}