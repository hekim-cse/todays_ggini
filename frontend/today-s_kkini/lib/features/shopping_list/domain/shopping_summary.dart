import 'shopping_list.dart' show ShoppingMarketCount;

// 백엔드 PATCH/DELETE 응답에 포함되는 summary 블록을 표현
//
// 응답: { updated_items: [...], summary: {...} } 또는
//       { deleted_count, deleted_item_ids, summary: {...} }
//
// summary 의 4개 필드는 ShoppingList 의 최상위 합계 필드와 동일 구조.
// market_groups 의 subtotal 은 응답에 없으므로 클라이언트에서 별도 계산 필요.
class ShoppingSummary {
  final int totalItems;
  final int checkedItemsCount;
  final int totalPricePerShopping;
  final List<ShoppingMarketCount> marketCounts;

  const ShoppingSummary({
    required this.totalItems,
    required this.checkedItemsCount,
    required this.totalPricePerShopping,
    required this.marketCounts,
  });

  factory ShoppingSummary.fromJson(Map<String, dynamic> json) {
    return ShoppingSummary(
      totalItems: (json['total_items'] as num).toInt(),
      checkedItemsCount: (json['checked_items_count'] as num).toInt(),
      totalPricePerShopping: (json['total_price_per_shopping'] as num).toInt(),
      marketCounts:
          (json['market_counts'] as List<dynamic>)
              .map(
                (e) => ShoppingMarketCount.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}
