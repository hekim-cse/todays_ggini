import 'package:dio/dio.dart';

import '../domain/ingredient_prices.dart';

class IngredientDetailRepository {
  final Dio _dio;
  IngredientDetailRepository(this._dio);

  // 재료별 마켓 가격 비교
  // 백엔드: GET /api/v1/shopping/ingredients/{ingredient_id}/prices
  // (백엔드에서 이 endpoint 는 인증 불필요)
  Future<IngredientPrices> fetchPrices(String ingredientId) async {
    final response = await _dio.get(
      '/shopping/ingredients/$ingredientId/prices',
    );
    return IngredientPrices.fromJson(response.data as Map<String, dynamic>);
  }
}
