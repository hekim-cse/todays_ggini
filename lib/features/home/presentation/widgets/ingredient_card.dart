import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../domain/menu_detail.dart';

class IngredientCard extends StatelessWidget {
  final int index;
  final Ingredient ingredient;

  const IngredientCard({
    super.key,
    required this.index,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '재료 $index: ${ingredient.ingredientName}',
            style: Theme.of(context).textTheme.bodyLarge
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildImage(context),
              const SizedBox(width: 12),
              Text(
                ingredient.standardUnit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: _buildPrices(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ingredient.imageUrl == null
          ? Center(
              child: Text(
                '이미지',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(ingredient.imageUrl!, fit: BoxFit.cover),
              ),
    );
  }

  Widget _buildPrices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _priceRow(context, '쿠팡', ingredient.prices.coupang,
            isLowest: ingredient.lowestPrice.market == 'coupang'),
        _priceRow(context, '컬리', ingredient.prices.marketKurly,
            isLowest: ingredient.lowestPrice.market == 'market_kurly'),
        _priceRow(context, '네이버', ingredient.prices.naverShopping,
            isLowest: ingredient.lowestPrice.market == 'naver_shopping'),
      ],
    );
  }

  Widget _priceRow(BuildContext context, String marketName, int? price,
      {required bool isLowest}) {
    final isAvailable = price != null;
    final color = !isAvailable
        ? AppColors.border
        : isLowest
            ? AppColors.primary
            : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              marketName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
          ),
          Text(
            isAvailable ? '₩${formatPrice(price)}' : '재고 없음',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
          if (isLowest && isAvailable) ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
