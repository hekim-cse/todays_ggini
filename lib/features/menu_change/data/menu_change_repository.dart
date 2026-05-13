import 'package:dio/dio.dart';

import '../../home/domain/daily_meal_plan.dart';
import '../domain/menu_alternatives.dart';

class MenuChangeRepository {
  final Dio _dio;

  MenuChangeRepository(this._dio);

  // GET /api/v1/meal/menus/{meal_id}/alternatives
  // 현재 메뉴를 기준으로 추천 대안 식단 목록 조회
  // 단, 현재 백엔드는 이 endpoint 를 commented out 상태로 둔 것으로 추정
  Future<MenuAlternatives> fetchAlternatives(String currentMealId) async {
    final response = await _dio.get('/meal/menus/$currentMealId/alternatives');
    return MenuAlternatives.fromJson(response.data as Map<String, dynamic>);
  }

  // PUT /api/v1/meal/{date}/menus/{slot}
  // 특정 날짜·슬롯의 메뉴를 새 meal_id 로 교체
  // body key 가 백엔드 스키마(MenuUpdateRequest)에 맞춰 'new_meal_id' 임에 주의
  Future<DailyMealPlan> changeMenu({
    required DateTime date,
    required int slot,
    required String newMealId,
  }) async {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final response = await _dio.put(
      '/meal/$y-$m-$d/menus/$slot',
      data: {'new_meal_id': newMealId},
    );
    return DailyMealPlan.fromJson(response.data as Map<String, dynamic>);
  }
}
