import 'package:dio/dio.dart';

import '../../../core/utils/format.dart';
import '../domain/daily_meal_plan.dart';
import '../domain/menu_detail.dart';

class HomeRepository {
  final Dio _dio;
  HomeRepository(this._dio);

  // 특정 날짜의 하루 식단 (slot별 요약 정보)
  // 백엔드: GET /api/v1/meal/{date}
  Future<DailyMealPlan> fetchDailyMealPlan(DateTime date) async {
    final dateStr = formatDate(date);
    final response = await _dio.get('/meal/$dateStr');
    return DailyMealPlan.fromJson(response.data as Map<String, dynamic>);
  }

  // 특정 메뉴의 상세 정보 (재료 + 마켓별 가격)
  Future<MenuDetail> fetchMenuDetail({
    required DateTime mealDate,
    required String mealId,
  }) async {
    final dateStr = formatDate(mealDate);
    final response = await _dio.get('/meal/menu/$dateStr/$mealId');
    return MenuDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
