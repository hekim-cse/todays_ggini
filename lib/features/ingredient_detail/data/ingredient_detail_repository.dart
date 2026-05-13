import 'package:dio/dio.dart';

import '../domain/ingredient_prices.dart';

class IngredientDetailRepository {
  final Dio _dio;
  IngredientDetailRepository(this._dio);

  // 재료별 마켓 가격 비교
  // API 명세서 10번: GET /ingredients/{ingredient_id}/prices
  Future<IngredientPrices> fetchPrices(String ingredientId) async {
    final response = await _dio.get('/ingredients/$ingredientId/prices');
    return IngredientPrices.fromJson(response.data as Map<String, dynamic>);
  }
}
