import 'package:dio/dio.dart';

import '../../home/domain/daily_meal_plan.dart';
import '../domain/menu_alternatives.dart';

class MenuChangeRepository {
  final Dio _dio;
  MenuChangeRepository(this._dio);

  Future<MenuAlternatives> fetchAlternatives(String currentMealId) async {
    // TODO: 백엔드 연동 후 mock 제거
    return _mockAlternatives(currentMealId);

    // 실제 API 호출
    // final response = await _dio.get('/menus/$currentMealId/alternatives');
    // return MenuAlternatives.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DailyMealPlan> changeMenu({
    required DateTime date,
    required int slot,
    required String newMealId,
  }) async {
    // TODO: 백엔드 연동 후 mock 제거
    return _mockChangedPlan(date, slot, newMealId);

    // 실제 API 호출
    // final y = date.year.toString().padLeft(4, '0');
    // final m = date.month.toString().padLeft(2, '0');
    // final d = date.day.toString().padLeft(2, '0');
    // final response = await _dio.put(
    //   '/meal-plans/$y-$m-$d/menus/$slot',
    //   data: {'meal_id': newMealId},
    // );
    // return DailyMealPlan.fromJson(response.data as Map<String, dynamic>);
  }

  MenuAlternatives _mockAlternatives(String currentMealId) {
    return MenuAlternatives(
      currentMeal: CurrentMeal(
        mealId: currentMealId,
        menuName: '볶음밥',
        calories: 650,
        price: 3600,
        date: DateTime.now(),
        slot: 1,
      ),
      alternatives: const [
        AlternativeMeal(
          mealId: 'ALT_001',
          menuName: '김치찌개',
          calories: 550,
          price: 3200,
        ),
        AlternativeMeal(
          mealId: 'ALT_002',
          menuName: '된장찌개',
          calories: 480,
          price: 2800,
        ),
        AlternativeMeal(
          mealId: 'ALT_003',
          menuName: '비빔밥',
          calories: 600,
          price: 3400,
        ),
      ],
    );
  }

  DailyMealPlan _mockChangedPlan(DateTime date, int slot, String newMealId) {
    return DailyMealPlan(
      date: date,
      caloriesPerDay: 1800,
      pricePerDay: 10000,
      meals: [
        MealSlotSummary(
          slot: slot,
          mealId: newMealId,
          menuName: '변경된 메뉴',
          calories: 600,
          price: 3400,
        ),
      ],
    );
  }
}