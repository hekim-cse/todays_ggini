import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class IngredientSelector extends StatelessWidget {
  final List<String> selectedIngredients;
  final ValueChanged<List<String>> onChanged;

  const IngredientSelector({
    super.key,
    required this.selectedIngredients,
    required this.onChanged,
  });

  final List<String> _ingredients = const ['육류', '해산물류', '채소류', '식물성 단백질류', '계란 및 유제품류'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '[선호 식재료]',
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
          children: _ingredients.map((ingredient) {
            final isSelected = selectedIngredients.contains(ingredient);
            return GestureDetector(
              onTap: () {
                final newList = List<String>.from(selectedIngredients);
                isSelected ? newList.remove(ingredient) : newList.add(ingredient);
                onChanged(newList);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ingredient,
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