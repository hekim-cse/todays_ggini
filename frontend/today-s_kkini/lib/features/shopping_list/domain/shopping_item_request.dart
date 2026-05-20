// POST /shopping/add-shopping-items payload 아이템.
//
// 백엔드 IngredientSelectRequest 스키마 완화 요청 (옵션 C) 기준:
//   필수: ingredient_id, market_name, is_checked, is_essential
//   Optional: ingredient_name, standard_unit, price, delivery_type,
//             product_title, purchase_link (백엔드가 DB에서 lookup)
//
// 만약 백엔드가 스키마 완화를 안 받아주면 추가 필드를 여기 더해서
// payload 만드는 자리(submitToShoppingList)에서 채워 보내야 함.
class ShoppingItemRequest {
  final String ingredientId;
  final String marketName;
  final bool isChecked;
  final bool isEssential;

  const ShoppingItemRequest({
    required this.ingredientId,
    required this.marketName,
    this.isChecked = true,
    this.isEssential = true,
  });

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'market_name': marketName,
    'is_checked': isChecked,
    'is_essential': isEssential,
  };
}

// submitToShoppingList 의 결과.
// success / 추가된 개수 / 스킵된 재료 / 에러 정보를 같이 반환.
class AddShoppingResult {
  final int addedCount;
  final List<String> skippedIngredientNames;
  final Object? error;

  const AddShoppingResult({
    required this.addedCount,
    required this.skippedIngredientNames,
    this.error,
  });

  bool get success => error == null;
}
