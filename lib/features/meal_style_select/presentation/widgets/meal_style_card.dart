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
          color: isSelected ? AppColors.mypage : AppColors.stylegray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.buttonGray,
            width: 2.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 태그
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                style.styleName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 메뉴 목록 + 설명
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      ...style.representativeMenus.map((meal) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Text('🍽️', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  meal,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 4),
                      Text(
                        style.summaryComment,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 오른쪽: 점수 바
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: style.displayScores.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                style.displayLabels[e.key] ?? e.key,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              width: e.value * 8.0,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getBarColor(e.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${e.value}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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