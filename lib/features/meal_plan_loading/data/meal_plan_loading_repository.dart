import 'package:dio/dio.dart';
import '../domain/meal_plan_job.dart';

class MealPlanLoadingRepository {
  final Dio _dio;
  // 서버와 HTTP 통신을 하기 위한 Dio 객체를 외부에서 주입
  MealPlanLoadingRepository(this._dio);

  Future<MealPlanJob> generateMealPlan() async {
    // 백엔드: POST /api/v1/meal/generate
    final response = await _dio.post('/meal/generate');
    // 서버 응답 데이터를 Map<String, dynamic>으로 변환한 뒤,
    // MealPlanJob.fromJson을 통해 Domain 객체로 변환
    return MealPlanJob.fromJson(response.data as Map<String, dynamic>);
  }
}
