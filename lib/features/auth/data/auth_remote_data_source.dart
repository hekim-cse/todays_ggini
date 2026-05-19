import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> loginWithKakao(String accessToken) async {
    final response = await _dio.post(
      '/api/v1/auth/kakao',
      data: {'accessToken': accessToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithNaver(String code) async {
    final response = await _dio.post(
      '/api/v1/auth/naver',
      data: {'code': code},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String accessToken) async {
    final response = await _dio.post(
      '/api/v1/auth/google',
      data: {'accessToken': accessToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post('/api/v1/auth/logout');
  }

  Future<Map<String, dynamic>> loginAsGuest() async {
    final response = await _dio.post(
      '/api/v1/auth/guest/init',
    );
    return response.data as Map<String, dynamic>;
  }
}