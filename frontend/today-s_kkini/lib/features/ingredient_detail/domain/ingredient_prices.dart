class IngredientPrices {
  final String ingredientId;
  final String ingredientName;
  final String standardUnit;
  final String? imageUrl;
  final Map<String, MarketPrice> marketPrices;

  const IngredientPrices({
    required this.ingredientId,
    required this.ingredientName,
    required this.standardUnit,
    this.imageUrl,
    required this.marketPrices,
  });

  // 가격 낮은 순으로 정렬된 마켓 리스트. 재고 없는 마켓은 맨 뒤
  List<MapEntry<String, MarketPrice>> get sortedByPrice {
    final entries = marketPrices.entries.toList();
    entries.sort((a, b) {
      // 재고 없으면(가격 null) 맨 뒤로
      if (a.value.lowestPrice == null && b.value.lowestPrice == null) return 0;
      if (a.value.lowestPrice == null) return 1;
      if (b.value.lowestPrice == null) return -1;
      return a.value.lowestPrice!.compareTo(b.value.lowestPrice!);
    });
    return entries;
  }

  factory IngredientPrices.fromJson(Map<String, dynamic> json) {
    final pricesJson = json['e_commerce_prices'] as Map<String, dynamic>;
    final prices = <String, MarketPrice>{};
    pricesJson.forEach((market, data) {
      // 마켓 자체가 null (재고 없음) → 빈 MarketPrice 로 채움
      if (data == null) {
        prices[market] = const MarketPrice();
      } else {
        prices[market] = MarketPrice.fromJson(data as Map<String, dynamic>);
      }
    });
    return IngredientPrices(
      ingredientId: json['ingredient_id'] as String,
      ingredientName: json['ingredient_name'] as String,
      standardUnit: json['standard_unit'] as String,
      imageUrl: json['image_url'] as String?,
      marketPrices: prices,
    );
  }
}

class MarketPrice {
  final String? deliveryType;
  final int? lowestPrice;
  final String? productTitle;
  final String? purchaseLink;
  final bool isLowest;

  const MarketPrice({
    this.deliveryType,
    this.lowestPrice,
    this.productTitle,
    this.purchaseLink,
    this.isLowest = false,
  });

  // 재고 있음 여부
  bool get isAvailable => lowestPrice != null;

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      deliveryType: json['delivery_type'] as String?,
      lowestPrice: (json['lowest_price'] as num?)?.toInt(),
      productTitle: json['product_title'] as String?,
      purchaseLink: json['purchase_link'] as String?,
      isLowest: json['is_lowest'] as bool? ?? false,
    );
  }
}
