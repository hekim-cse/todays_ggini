import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../home/domain/menu_detail.dart';

class IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final bool isChecked;
  final String? selectedMarket;
  final VoidCallback onToggle;
  final VoidCallback onTapDetail;

  const IngredientRow({
    super.key,
    required this.ingredient,
    required this.isChecked,
    this.selectedMarket,
    required this.onToggle,
    required this.onTapDetail,
  });

  @override
  Widget build(BuildContext context) {
    final lowest = ingredient.lowestPrice;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  isChecked
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.ingredientName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${ingredient.standardUnit} 이상',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₩${formatPrice(lowest.price)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_marketLabel(lowest.market)} 최저가',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            color: AppColors.textPrimary,
            onPressed: onTapDetail,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  String _marketLabel(String market) {
    switch (market) {
      case 'coupang':
        return '쿠팡';
      case 'market_kurly':
        return '컬리';
      case 'naver_shopping':
        return '네이버';
      default:
        return market;
    }
  }
}
