import 'package:dio/dio.dart';

import '../../../core/utils/format.dart';
import '../domain/monthly_meal_plan.dart';

class CalendarRepository {
  final Dio _dio;
  CalendarRepository(this._dio);

  // 특정 월의 식단 캘린더 데이터
  // API 명세서 3번: GET /meal-plans/calendar?month=YYYY-MM
  Future<MonthlyMealPlan> fetchMonth(int year, int month) async {
    final monthStr = formatYearMonth(year, month);
    final response = await _dio.get(
      '/meal-plans/calendar',
      queryParameters: {'month': monthStr},
    );
    return MonthlyMealPlan.fromJson(response.data as Map<String, dynamic>);
  }
}
