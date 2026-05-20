// 메뉴 변경 화면 (#10-3) 도메인 모델
//
// API #12 GET /menus/{meal_id}/alternatives 응답 매핑
// PUT /meal-plans/{date}/menus/{slot} 응답은 DailyMealPlan 재사용
// (lib/features/home/domain/daily_meal_plan.dart)

class MenuAlternatives {
  final CurrentMeal currentMeal;
  final List<AlternativeMeal> alternatives;

  const MenuAlternatives({
    required this.currentMeal,
    required this.alternatives,
  });

  factory MenuAlternatives.fromJson(Map<String, dynamic> json) {
    return MenuAlternatives(
      currentMeal: CurrentMeal.fromJson(
        json['current_meal'] as Map<String, dynamic>,
      ),
      alternatives:
          (json['alternatives'] as List<dynamic>)
              .map((e) => AlternativeMeal.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

// 현재 식단의 끼니 정보. date / slot 을 포함하는 점이 [AlternativeMeal] 와 다름
class CurrentMeal {
  final String mealId;
  final String menuName;
  final int calories;
  final int price;
  final String? imageUrl;
  final DateTime date;
  final int slot;

  const CurrentMeal({
    required this.mealId,
    required this.menuName,
    required this.calories,
    required this.price,
    this.imageUrl,
    required this.date,
    required this.slot,
  });

  factory CurrentMeal.fromJson(Map<String, dynamic> json) {
    return CurrentMeal(
      mealId: json['meal_id'] as String,
      menuName: json['menu_name'] as String,
      calories: (json['calories'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      date: DateTime.parse(json['date'] as String),
      slot: json['slot'] as int,
    );
  }
}

// 추천 대안 식단 한 개
class AlternativeMeal {
  final String mealId;
  final String menuName;
  final int calories;
  final int price;
  final String? imageUrl;

  const AlternativeMeal({
    required this.mealId,
    required this.menuName,
    required this.calories,
    required this.price,
    this.imageUrl,
  });

  factory AlternativeMeal.fromJson(Map<String, dynamic> json) {
    return AlternativeMeal(
      mealId: json['meal_id'] as String,
      menuName: json['menu_name'] as String,
      calories: (json['calories'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
    );
  }
}
