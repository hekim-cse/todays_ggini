import 'package:dio/dio.dart';
import '../domain/meal_plan_job.dart';

class MealPlanLoadingRepository {
  final Dio _dio;
  MealPlanLoadingRepository(this._dio);

  Future<MealPlanJob> generateMealPlan() async {
    // TODO: 백엔드 연동 후 mock 제거
    return _mockJob();

    // 실제 API 호출
    // final response = await _dio.post('/meal-plans/generate');
    // return MealPlanJob.fromJson(response.data as Map<String, dynamic>);
  }

  MealPlanJob _mockJob() {
    return const MealPlanJob(
      jobId: 'mock-job-001',
      estimatedSeconds: 4,
      stages: ['프로필 분석', '식단 후보 생성', '가격 비교', '최적 조합 선정'],
    );
  }
}