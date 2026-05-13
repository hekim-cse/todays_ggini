class MenuDetail {
  final String mealId;
  final String menuName;
  final int calories;
  final int price;
  final String? imageUrl;
  final String? videoUrl;
  final List<Ingredient> ingredients;

  const MenuDetail({
    required this.mealId,
    required this.menuName,
    required this.calories,
    required this.price,
    this.imageUrl,
    this.videoUrl,
    required this.ingredients,
  });

  factory MenuDetail.fromJson(Map<String, dynamic> json) {
    // 서버 응답 예:
    // ```json
    // {
    //     "date": "2026-04-06",
    //     "calories_per_day": 1850,
    //     "price_per_day": 10800,
    //     "meals": [
    //         {
    //             "slot": 1,
    //             "meal_id": "M_001",
    //             "menu_name": "볶음밥",
    //             "calories": 650,
    //             "price": 3600,
    //             "image_url": null
    //         },
    //         {
    //             "slot": 2,
    //             "meal_id": "M_002",
    //             "menu_name": "콩나물국",
    //             "calories": 550,
    //             "price": 3600,
    //             "image_url": null
    //         },
    //         {
    //             "slot": 3,
    //             "meal_id": "M_003",
    //             "menu_name": "제철 나물 비빔밥",
    //             "calories": 650,
    //             "price": 3600,
    //             "image_url": null
    //         }
    //     ]
    // }
    // ```
    return MenuDetail(
      mealId: json['meal_id'] as String,
      menuName: json['menu_name'] as String,
      calories: json['calories'] as int,
      price: json['price'] as int,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      ingredients:
          (json['ingredients'] as List)
              .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
              .toList(),
    );
  }
}

class Ingredient {
  final String ingredientId;
  final String ingredientName;
  final String standardUnit;
  final String? imageUrl;
  final LowestPrice lowestPrice;
  final EcommercePrices prices;

  const Ingredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.standardUnit,
    this.imageUrl,
    required this.lowestPrice,
    required this.prices,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientId: json['ingredient_id'] as String,
      ingredientName: json['ingredient_name'] as String,
      standardUnit: json['standard_unit'] as String,
      imageUrl: json['image_url'] as String?,
      lowestPrice: LowestPrice.fromJson(
        json['lowest_price_between_market'] as Map<String, dynamic>,
      ),
      prices: EcommercePrices.fromJson(
        json['e_commerce_prices'] as Map<String, dynamic>,
      ),
    );
  }
}

class LowestPrice {
  final String market;
  final int price;

  const LowestPrice({required this.market, required this.price});

  factory LowestPrice.fromJson(Map<String, dynamic> json) {
    return LowestPrice(
      market: json['market'] as String,
      price: json['price'] as int,
    );
  }
}

// 쿠팡/컬리/네이버 가격으로 어느 마켓이든 재고 없는 null일 수 있음
class EcommercePrices {
  final int? coupang;
  final int? marketKurly;
  final int? naverShopping;

  const EcommercePrices({this.coupang, this.marketKurly, this.naverShopping});

  factory EcommercePrices.fromJson(Map<String, dynamic> json) {
    int? extract(String key) {
      final m = json[key];
      if (m == null) return null;
      return (m as Map<String, dynamic>)['lowest_price'] as int?;
    }

    return EcommercePrices(
      coupang: extract('coupang'),
      marketKurly: extract('market_kurly'),
      naverShopping: extract('naver_shopping'),
    );
  }
}
