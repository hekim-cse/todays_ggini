import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> loginWithKakao(String accessToken) async {
    final response = await _dio.post(
      '/auth/kakao',
      data: {'access_token': accessToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithNaver(String accessToken) async {
    final response = await _dio.post(
      '/auth/naver',
      data: {'access_token': accessToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String accessToken) async {
    final response = await _dio.post(
      '/auth/google',
      data: {'access_token': accessToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithApple(String identityToken) async {
    final response = await _dio.post(
      '/auth/apple',
      data: {'identity_token': identityToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
}