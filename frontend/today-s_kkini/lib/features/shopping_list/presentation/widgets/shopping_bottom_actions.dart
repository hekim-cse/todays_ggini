import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ShoppingBottomActions extends StatelessWidget {
  final bool hasCheckedItems;
  final VoidCallback onDeleteChecked;
  final VoidCallback onCheckoutByMarket;

  const ShoppingBottomActions({
    super.key,
    required this.hasCheckedItems,
    required this.onDeleteChecked,
    required this.onCheckoutByMarket,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasCheckedItems ? onDeleteChecked : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.buttonGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
            ),
            child: Text(
              '선택 항목 제거',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: hasCheckedItems
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasCheckedItems ? onCheckoutByMarket : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.buttonGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              '마켓별 한 번에 구매하기',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: hasCheckedItems
                  ? Colors.white
                  : AppColors.textSecondary,
              )
            ),
          ),
        ),
      ],
    );
  }
}
