import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MealSlotTabs extends StatelessWidget {
  final int slotCount;
  final int selectedSlot;
  final ValueChanged<int> onSlotSelected;

  const MealSlotTabs({
    super.key,
    required this.slotCount,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(slotCount, (i) {
        final slot = i + 1;
        final isSelected = slot == selectedSlot;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSlotSelected(slot),
            child: Container(
              margin: EdgeInsets.only(right: i < slotCount - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mypage : AppColors.buttonGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '식단 $slot',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}