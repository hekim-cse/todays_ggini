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
    try {
      final response = await _dio.get('/meal/$dateStr');
      return DailyMealPlan.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // 식단이 없는 날은 에러가 아니라 "빈 날"로 정상 처리
      if (e.response?.statusCode == 404) {
        return DailyMealPlan.empty(date);
      }
      rethrow; // 나머지 에러(500, 네트워크 등)는 그대로 위로 전달
    }
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
