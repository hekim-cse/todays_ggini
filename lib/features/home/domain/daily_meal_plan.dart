class DailyMealPlan {
  final DateTime date;
  final int caloriesPerDay;
  final int pricePerDay;
  final List<MealSlotSummary> meals;

  const DailyMealPlan({
    required this.date,
    required this.caloriesPerDay,
    required this.pricePerDay,
    required this.meals,
  });

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      date: DateTime.parse(json['date'] as String),
      caloriesPerDay: (json['calories_per_day'] as num).toInt(),
      pricePerDay: (json['price_per_day'] as num).toInt(),
      meals:
          (json['meals'] as List)
              .map((m) => MealSlotSummary.fromJson(m as Map<String, dynamic>))
              .toList(),
    );
  }
}

// 한 슬롯(끼니) 정보 — 끼니 수에 따라 1~5개
class MealSlotSummary {
  final int slot;
  final String mealId;
  final String menuName;
  final int calories;
  final int price;
  final String? imageUrl;

  const MealSlotSummary({
    required this.slot,
    required this.mealId,
    required this.menuName,
    required this.calories,
    required this.price,
    this.imageUrl,
  });

  factory MealSlotSummary.fromJson(Map<String, dynamic> json) {
    return MealSlotSummary(
      slot: json['slot'] as int,
      mealId: json['meal_id'] as String,
      menuName: json['menu_name'] as String,
      calories: (json['calories'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
    );
  }
}
