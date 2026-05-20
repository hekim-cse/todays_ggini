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

  // Widget _buildRow(BuildContext context, List<String> items) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       // 각 항목의 글자 너비 계산
  //       final textStyle = Theme.of(context).textTheme.bodyMedium;
  //       final horizontalPadding = 16.0 * 2; // 좌우 패딩
  //       final spacing = 8.0;

  //       double totalTextWidth = 0;
  //       for (final food in items) {
  //         final tp = TextPainter(
  //           text: TextSpan(text: food, style: textStyle),
  //           textDirection: TextDirection.ltr,
  //         )..layout();
  //         totalTextWidth += tp.width + horizontalPadding;
  //       }
  //       totalTextWidth += spacing * (items.length - 1);

  //       // 남은 여백을 항목 수로 나눔
  //       final extraPerItem = (constraints.maxWidth - totalTextWidth) > 0
  //           ? (constraints.maxWidth - totalTextWidth) / items.length
  //           : 0.0;

  //       return Row(
  //         children: items.asMap().entries.map((entry) {
  //           final index = entry.key;
  //           final food = entry.value;
  //           final isSelected = selectedFoods.contains(food);

  //           return Container(
  //             margin: EdgeInsets.only(right: index < items.length - 1 ? spacing : 0),
  //             padding: EdgeInsets.symmetric(
  //               horizontal: 16 + extraPerItem / 2,
  //               vertical: 10,
  //             ),
  //             decoration: BoxDecoration(
  //               color: isSelected ? AppColors.primary : AppColors.buttonGray,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: GestureDetector(
  //               onTap: () {
  //                 final newList = List<String>.from(selectedFoods);
  //                 isSelected ? newList.remove(food) : newList.add(food);
  //                 onChanged(newList);
  //               },
  //               child: Text(
  //                 food,
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
        final food = entry.value;
        final isSelected = selectedFoods.contains(food);
        return Expanded(
          child: GestureDetector(
            onTap: () {
              final newList = List<String>.from(selectedFoods);
              isSelected ? newList.remove(food) : newList.add(food);
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
                      food,
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
          '[취향]',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // 한 줄에 다 들어가는지 계산
              final textStyle = Theme.of(context).textTheme.bodyMedium;
              double totalWidth = 0;
              for (final food in _foods) {
                final tp = TextPainter(
                  text: TextSpan(text: food, style: textStyle),
                  textDirection: TextDirection.ltr,
                )..layout();
                totalWidth += tp.width + 32; // 좌우 패딩
              }
              totalWidth += 8 * (_foods.length - 1); // spacing

              if (totalWidth <= constraints.maxWidth) {
                return _buildRow(context, _foods);
              } else {
                return Column(
                  children: [
                    _buildRow(context, _foods.sublist(0, 5)),
                    const SizedBox(height: 8),
                    _buildRow(context, _foods.sublist(5)),
                  ],
                );
              }
            },
          ),
      ],
    );
  }
}