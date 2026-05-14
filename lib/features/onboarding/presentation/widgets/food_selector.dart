import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FoodSelector extends StatelessWidget {
  final List<String> selectedFoods;
  final ValueChanged<List<String>> onChanged;

  const FoodSelector({
    super.key,
    required this.selectedFoods,
    required this.onChanged,
  });

  final List<String> _foods = const ['한식', '중식', '일식', '양식', '분식', '패스트푸드', '샐러드/건강식', '다 좋아요'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '[취향]',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _foods.map((food) {
            final isSelected = selectedFoods.contains(food);
            return GestureDetector(
              onTap: () {
                final newList = List<String>.from(selectedFoods);
                isSelected ? newList.remove(food) : newList.add(food);
                onChanged(newList);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  food,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}