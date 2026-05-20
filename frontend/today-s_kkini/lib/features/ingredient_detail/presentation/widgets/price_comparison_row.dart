import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../domain/ingredient_prices.dart';

class PriceComparisonRow extends StatelessWidget {
  final String market;
  final MarketPrice price;
  final bool isUserSelected;
  final VoidCallback onSelect;

  const PriceComparisonRow({
    super.key,
    required this.market,
    required this.price,
    required this.isUserSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = price.isAvailable;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUserSelected
              ? AppColors.primary
              : AppColors.border,
          width: isUserSelected ? 1 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  _marketLabel(market),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                if (price.isLowest && isAvailable) ...[
                  const SizedBox(width: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '최저',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              isAvailable
                  ? '₩${formatPrice(price.lowestPrice!)}'
                  : '재고 없음',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isAvailable
                        ? AppColors.textPrimary
                        : AppColors.border,
                  ),
            ),
          ),

          OutlinedButton(
            onPressed: isAvailable ? onSelect : null,

            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),

              side: BorderSide(
                color: isUserSelected
                    ? AppColors.primary
                    : (isAvailable
                        ? AppColors.primary
                        : AppColors.border),
                width: isUserSelected ? 1 : 1,
              ),

              backgroundColor: isUserSelected
                  ? AppColors.primary
                  : Colors.transparent,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              fixedSize: const Size(80, 40),
            ),

            child: Text(
              isUserSelected ? '선택됨' : '선택',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUserSelected
                    ? Colors.white
                    : (isAvailable
                        ? AppColors.primary
                        : AppColors.border),
              ),
            ),
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
