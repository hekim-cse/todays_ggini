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

  // Widget _buildRow(BuildContext context, List<String> items) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final textStyle = Theme.of(context).textTheme.bodyMedium;
  //       final horizontalPadding = 16.0 * 2;
  //       final spacing = 8.0;

  //       double totalTextWidth = 0;
  //       for (final ingredient in items) {
  //         final tp = TextPainter(
  //           text: TextSpan(text: ingredient, style: textStyle),
  //           textDirection: TextDirection.ltr,
  //         )..layout();
  //         totalTextWidth += tp.width + horizontalPadding;
  //       }
  //       totalTextWidth += spacing * (items.length - 1);

  //       final extraPerItem = (constraints.maxWidth - totalTextWidth) > 0
  //           ? (constraints.maxWidth - totalTextWidth) / items.length
  //           : 0.0;

  //       return Row(
  //         children: items.asMap().entries.map((entry) {
  //           final index = entry.key;
  //           final ingredient = entry.value;
  //           final isSelected = selectedIngredients.contains(ingredient);

  //           return GestureDetector(
  //             onTap: () {
  //               final newList = List<String>.from(selectedIngredients);
  //               isSelected ? newList.remove(ingredient) : newList.add(ingredient);
  //               onChanged(newList);
  //             },
  //             child: Container(
  //               margin: EdgeInsets.only(right: index < items.length - 1 ? spacing : 0),
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: 16 + extraPerItem / 2,
  //                 vertical: 10,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: isSelected ? AppColors.primary : AppColors.buttonGray,
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Text(
  //                 ingredient,
  //                 style: textStyle?.copyWith(
  //                   color: isSelected ? Colors.white : AppColors.textPrimary,
  //                 ),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }

  Widget _buildRow(BuildContext context, List<String> items) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final ingredient = entry.value;
        final isSelected = selectedIngredients.contains(ingredient);
        return Expanded(
          child: GestureDetector(
            onTap: () {
              final newList = List<String>.from(selectedIngredients);
              isSelected ? newList.remove(ingredient) : newList.add(ingredient);
              onChanged(newList);
            },
            child: Container(
              margin: EdgeInsets.only(right: index < items.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.buttonGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      ingredient,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '[선호 식재료]',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final textStyle = Theme.of(context).textTheme.bodyMedium;
            double totalWidth = 0;
            for (final ingredient in _ingredients) {
              final tp = TextPainter(
                text: TextSpan(text: ingredient, style: textStyle),
                textDirection: TextDirection.ltr,
              )..layout();
              totalWidth += tp.width + 32;
            }
            totalWidth += 8 * (_ingredients.length - 1);

            if (totalWidth <= constraints.maxWidth) {
              return _buildRow(context, _ingredients);
            } else {
              return Column(
                children: [
                  _buildRow(context, _ingredients.sublist(0, 3)),
                  const SizedBox(height: 8),
                  _buildRow(context, _ingredients.sublist(3)),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}