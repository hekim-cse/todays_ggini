import 'package:dio/dio.dart';

class OnboardingRemoteDataSource {
  OnboardingRemoteDataSource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> patchOnboarding(
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/user/onboarding',
      data: body,
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Empty response from /user/onboarding');
    }
    return data;
  }
}
