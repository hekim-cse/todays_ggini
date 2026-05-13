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
          height: 48,
          child: OutlinedButton(
            onPressed: hasCheckedItems ? onDeleteChecked : null,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.background,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              '선택 항목 제거',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: hasCheckedItems ? onCheckoutByMarket : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.surfaceDim,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: const Text(
              '마켓별 한번에 구매하기',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}