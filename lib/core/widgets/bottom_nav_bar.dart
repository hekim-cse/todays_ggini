import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': '홈'},
      {'icon': Icons.calendar_month_outlined, 'activeIcon': Icons.calendar_month, 'label': '캘린더'},
      {'icon': Icons.shopping_cart_outlined, 'activeIcon': Icons.shopping_cart, 'label': '장보기'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': '마이'},
    ];

    final routes = [
      AppRoutes.home,
      AppRoutes.calendar,
      AppRoutes.shoppingList,
      AppRoutes.myPage,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 2, thickness: 2, color: AppColors.textSecondary),
        Container(
          color: AppColors.background,
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    context.go(routes[index]); 
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < items.length - 1
                            ? BorderSide(color: AppColors.textSecondary, width: 2)
                            : BorderSide.none,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? items[index]['activeIcon'] as IconData
                              : items[index]['icon'] as IconData,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index]['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}