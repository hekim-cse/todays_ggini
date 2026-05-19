import 'package:dio/dio.dart';

class MealStyleSelectRemoteDataSource {
  MealStyleSelectRemoteDataSource(this._dio);
  final Dio _dio;

  // 3일치 샘플 식단 후보 생성
  Future<Map<String, dynamic>> fetchStyleCandidates() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/meal/generate_sample_3days',
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Empty response from /meal/generate_sample_3days');
    }
    return data;
  }
}