import 'package:dio/dio.dart';

import '../../home/domain/daily_meal_plan.dart';
import '../domain/menu_alternatives.dart';

class MenuChangeRepository {
  final Dio _dio;

  MenuChangeRepository(this._dio);

  // API #12: GET /menus/{meal_id}/alternatives
  // 현재 메뉴를 기준으로 추천 대안 식단 목록 조회
  Future<MenuAlternatives> fetchAlternatives(String currentMealId) async {
    final response = await _dio.get('/menus/$currentMealId/alternatives');
    return MenuAlternatives.fromJson(response.data as Map<String, dynamic>);
  }

  // API #11: PUT /meal-plans/{date}/menus/{slot}
  // 특정 날짜·슬롯의 메뉴를 새 meal_id 로 교체
  // 응답: 변경 반영된 그 날 하루치 전체 식단 (DailyMealPlan)
  Future<DailyMealPlan> changeMenu({
    required DateTime date,
    required int slot,
    required String newMealId,
  }) async {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final response = await _dio.put(
      '/meal-plans/$y-$m-$d/menus/$slot',
      data: {'meal_id': newMealId},
    );
    return DailyMealPlan.fromJson(response.data as Map<String, dynamic>);
  }
}
