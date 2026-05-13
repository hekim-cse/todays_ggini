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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(slotCount, (i) {
        final slot = i + 1;
        final isSelected = slot == selectedSlot;

        return Expanded(
          child: InkWell(
            onTap: () => onSlotSelected(slot),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    '식단 $slot',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2,
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}