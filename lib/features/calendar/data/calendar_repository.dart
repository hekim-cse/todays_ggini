// import 'package:dio/dio.dart';
// import '../domain/monthly_meal_plan.dart';

// class CalendarRepository {
//   final Dio _dio;
//   CalendarRepository(this._dio);

//   Future<MonthlyMealPlan> fetchMonth(int year, int month) async {
//     // TODO: 백엔드 연동 후 mock 제거
//     return _mockPlan(year, month);

//     // 실제 API 호출 (백엔드 준비되면 아래 사용)
//     // final monthStr = '$year-${month.toString().padLeft(2, '0')}';
//     // final response = await _dio.get(
//     //   '/meal-plans/calendar',
//     //   queryParameters: {'month': monthStr},
//     // );
//     // return MonthlyMealPlan.fromJson(
//     //   response.data as Map<String, dynamic>,
//     // );
//   }

//   MonthlyMealPlan _mockPlan(int year, int month) {
//     final monthStr = '$year-${month.toString().padLeft(2, '0')}';
//     final daysInMonth = DateTime(year, month + 1, 0).day;
//     final days = <DayEntry>[];

//     for (var d = 1; d <= daysInMonth; d++) {
//       final date = DateTime(year, month, d);
//       days.add(
//         DayEntry(
//           date: date,
//           meals: [
//             DayMeal(slot: 1, mealId: 'mock-1', menuName: '김치찌개'),
//             DayMeal(slot: 2, mealId: 'mock-2', menuName: '된장국'),
//           ],
//           caloriesPerDay: 1800 + (d * 10),
//           pricePerDay: 8000 + (d * 100),
//         ),
//       );
//     }

//     return MonthlyMealPlan(
//       month: monthStr,
//       durationDays: daysInMonth,
//       days: days,
//       totalPricePerMonth: 240000,
//       averageCaloriesPerMonth: 1850,
//     );
//   }
// }

import 'package:dio/dio.dart';

import '../domain/monthly_meal_plan.dart';

class CalendarRepository {
  final Dio _dio;
  CalendarRepository(this._dio);

  // 특정 월의 식단 캘린더 데이터
  // API 명세서 3번: GET /meal-plans/calendar?month=YYYY-MM
  Future<MonthlyMealPlan> fetchMonth(int year, int month) async {
    final monthStr =
        '$year-${month.toString().padLeft(2, '0')}';

    final response = await _dio.get(
      '/meal-plans/calendar',
      queryParameters: {'month': monthStr},
    );

    return MonthlyMealPlan.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}