import 'package:dio/dio.dart';
import '../domain/ingredient_prices.dart';

class IngredientDetailRepository {
  final Dio _dio;
  IngredientDetailRepository(this._dio);

  Future<IngredientPrices> fetchPrices(String ingredientId) async {
    // TODO: 백엔드 연동 후 mock 제거
    return _mockPrices(ingredientId);

    // 실제 API 호출
    // final response = await _dio.get('/ingredients/$ingredientId/prices');
    // return IngredientPrices.fromJson(response.data as Map<String, dynamic>);
  }

  IngredientPrices _mockPrices(String ingredientId) {
    return IngredientPrices(
      ingredientId: ingredientId,
      ingredientName: '계란',
      standardUnit: '10개',
      marketPrices: <String, MarketPrice>{
        'coupang': const MarketPrice(
          deliveryType: 'rocket',
          lowestPrice: 2990,
          productTitle: '풀무원 신선란 10구',
          purchaseLink: 'https://coupang.com',
          isLowest: true,
        ),
        'market_kurly': const MarketPrice(
          deliveryType: 'normal',
          lowestPrice: 3200,
          productTitle: '유기농 계란 10개',
          purchaseLink: 'https://kurly.com',
          isLowest: false,
        ),
        'naver_shopping': const MarketPrice(
          deliveryType: 'normal',
          lowestPrice: 3100,
          productTitle: '국내산 계란 10구',
          purchaseLink: 'https://shopping.naver.com',
          isLowest: false,
        ),
      },
    );
  }
}