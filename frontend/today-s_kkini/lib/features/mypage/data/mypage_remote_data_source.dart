import 'package:dio/dio.dart';

class MyPageRemoteDataSource {
  MyPageRemoteDataSource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> fetchMyProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/user/me');
    final data = response.data;
    if (data == null) {
      throw Exception('Empty response from /user/me');
    }
    return data;
  }
}