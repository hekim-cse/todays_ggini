import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';  // ← 추가
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
        border: Border.all(color: AppColors.border),  // ← 변경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '재료 $index: ${ingredient.ingredientName}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,  // ← 변경
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildImage(),
              const SizedBox(width: 12),
              Text(
                ingredient.standardUnit,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,  // ← 변경
                ),
              ),
              const Spacer(),
              _buildPrices(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.border,  // ← 변경
        borderRadius: BorderRadius.circular(6),
      ),
      child: ingredient.imageUrl == null
          ? const Center(
              child: Text(
                '이미지',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,  // ← 변경
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(ingredient.imageUrl!, fit: BoxFit.cover),
            ),
    );
  }

  Widget _buildPrices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _priceRow(
          '쿠팡',
          ingredient.prices.coupang,
          isLowest: ingredient.lowestPrice.market == 'coupang',
        ),
        _priceRow(
          '컬리',
          ingredient.prices.marketKurly,
          isLowest: ingredient.lowestPrice.market == 'market_kurly',
        ),
        _priceRow(
          '네이버',
          ingredient.prices.naverShopping,
          isLowest: ingredient.lowestPrice.market == 'naver_shopping',
        ),
      ],
    );
  }

  Widget _priceRow(String marketName, int? price, {required bool isLowest}) {
    final isAvailable = price != null;
    final color = !isAvailable
        ? AppColors.border        // ← 변경
        : isLowest
            ? AppColors.primary   // ← 변경
            : AppColors.textPrimary; // ← 변경

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              marketName,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
          Text(
            isAvailable ? '₩${formatPrice(price)}' : '재고 없음',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isLowest ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
          if (isLowest && isAvailable) ...[
            const SizedBox(width: 6),
            Text(
              '최저가',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,  // ← 변경
              ),
            ),
          ],
        ],
      ),
    );
  }
}