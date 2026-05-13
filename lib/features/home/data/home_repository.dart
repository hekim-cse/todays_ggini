import 'package:dio/dio.dart';

import '../domain/daily_meal_plan.dart';
import '../domain/menu_detail.dart';

class HomeRepository {
  final Dio _dio;
  HomeRepository(this._dio);

  Future<DailyMealPlan> fetchDailyMealPlan(DateTime date) async {
    // TODO: 백엔드 연동 후 mock 제거
    return _mockDailyPlan(date);

    // 실제 API 호출
    // final dateStr = formatDate(date);
    // final response = await _dio.get('/meal-plans/$dateStr');
    // return DailyMealPlan.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MenuDetail> fetchMenuDetail(String mealId) async {
    // TODO: 백엔드 연동 후 mock 제거
    return _mockMenuDetail(mealId);

    // 실제 API 호출
    // final response = await _dio.get('/menus/$mealId');
    // return MenuDetail.fromJson(response.data as Map<String, dynamic>);
  }

  DailyMealPlan _mockDailyPlan(DateTime date) {
    return DailyMealPlan(
      date: date,
      caloriesPerDay: 1850,
      pricePerDay: 10800,
      meals: [
        MealSlotSummary(
          slot: 1,
          mealId: 'M_001',
          menuName: '볶음밥',
          calories: 650,
          price: 3600,
        ),
        MealSlotSummary(
          slot: 2,
          mealId: 'M_002',
          menuName: '콩나물국',
          calories: 550,
          price: 3600,
        ),
        MealSlotSummary(
          slot: 3,
          mealId: 'M_003',
          menuName: '제철 나물 비빔밥',
          calories: 650,
          price: 3600,
        ),
      ],
    );
  }

  MenuDetail _mockMenuDetail(String mealId) {
    final menuNames = {
      'M_001': '볶음밥',
      'M_002': '콩나물국',
      'M_003': '제철 나물 비빔밥',
    };

    return MenuDetail(
      mealId: mealId,
      menuName: menuNames[mealId] ?? '메뉴',
      calories: 650,
      price: 3600,
      videoUrl: null,
      ingredients: [
        Ingredient(
          ingredientId: 'I_001',
          ingredientName: '계란',
          standardUnit: '2개',
          lowestPrice: const LowestPrice(market: 'coupang', price: 1200),
          prices: const EcommercePrices(
            coupang: 1200,
            marketKurly: 1500,
            naverShopping: 1300,
          ),
        ),
        Ingredient(
          ingredientId: 'I_002',
          ingredientName: '김치',
          standardUnit: '100g',
          lowestPrice: const LowestPrice(market: 'market_kurly', price: 800),
          prices: const EcommercePrices(
            coupang: 900,
            marketKurly: 800,
            naverShopping: 950,
          ),
        ),
      ],
    );
  }
}