import 'package:dio/dio.dart';
import '../domain/meal_plan_job.dart';

class MealPlanLoadingRepository {
  final Dio _dio;
  MealPlanLoadingRepository(this._dio);

  /// 식단 생성 시작 — job_id 받음
  Future<MealPlanJob> startGeneration(String selectedStyleId) async {
    final response = await _dio.post(
      '/meal/generate',
      data: {'selected_style_id': selectedStyleId},
    );
    return MealPlanJob.fromJson(response.data as Map<String, dynamic>);
  }

  /// job 상태 폴링 — COMPLETED 될 때까지 대기
  /// progress 콜백으로 진행 상태 전달
  Future<void> pollUntilComplete(
    String jobId, {
    void Function(String progress)? onProgress,
  }) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final resp = await _dio.get('/meal/generate/status/$jobId');
      final data = resp.data as Map<String, dynamic>;
      final status = data['status'] as String;
      final progress = data['progress'] as String? ?? '';

      onProgress?.call(progress);

      if (status == 'COMPLETED') return;
      if (status == 'FAILED') {
        throw Exception(data['error'] ?? '식단 생성 실패');
      }
    }
  }
}
