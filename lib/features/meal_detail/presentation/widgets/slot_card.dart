import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../home/domain/daily_meal_plan.dart';

class SlotCard extends StatelessWidget {
  final MealSlotSummary meal;
  final VoidCallback onSelectIngredients;
  final VoidCallback onChangeMenu;

  const SlotCard({
    super.key,
    required this.meal,
    required this.onSelectIngredients,
    required this.onChangeMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(6),
            ),
            child:
                meal.imageUrl == null
                    ? Center(
                      child: Text(
                        '이미지',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(meal.imageUrl!, fit: BoxFit.cover),
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '식단 ${meal.slot}) ${meal.menuName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // const SizedBox(height: 2),
                const SizedBox(height: 4),
                Text(
                  '${formatPrice(meal.calories)} kcal · ₩${formatPrice(meal.price)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _smallButton(context, '재료 선택', onSelectIngredients)),
                    const SizedBox(width: 8),
                    Expanded(child: _smallButton(context, '메뉴 변경', onChangeMenu)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallButton(BuildContext context, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(0, 40),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
