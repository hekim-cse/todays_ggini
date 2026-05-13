import 'package:dio/dio.dart';

import '../domain/shopping_list.dart';

class ShoppingListRepository {
  final Dio _dio;

  ShoppingListRepository(this._dio);

  // 장보기 목록 조회
  // API 명세서 7번: GET /shopping-list
  Future<ShoppingList> fetchShoppingList() async {
    final response = await _dio.get('/shopping-list');
    return ShoppingList.fromJson(response.data as Map<String, dynamic>);
  }
}
