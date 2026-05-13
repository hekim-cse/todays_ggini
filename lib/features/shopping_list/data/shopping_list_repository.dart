import 'package:dio/dio.dart';
import '../domain/shopping_list.dart';

class ShoppingListRepository {
  final Dio _dio;
  ShoppingListRepository(this._dio);

  Future<ShoppingList> fetchShoppingList() async {
    // TODO: 백엔드 연동 후 mock 제거
    return _mockShoppingList();

    // 실제 API 호출
    // final response = await _dio.get('/shopping-list');
    // return ShoppingList.fromJson(response.data as Map<String, dynamic>);
  }

  ShoppingList _mockShoppingList() {
    return ShoppingList(
      totalItems: 4,
      checkedItemsCount: 4,
      totalPricePerShopping: 12000,
      marketCounts: const [
        ShoppingMarketCount(market: 'coupang', count: 2),
        ShoppingMarketCount(market: 'market_kurly', count: 1),
        ShoppingMarketCount(market: 'naver_shopping', count: 1),
      ],
      marketGroups: [
        ShoppingMarketGroup(
          market: 'coupang',
          subtotal: 6000,
          items: const [
            ShoppingItem(
              itemId: 'item_001',
              ingredientId: 'I_001',
              ingredientName: '계란',
              standardUnit: '10개',
              deliveryType: 'rocket',
              lowestPrice: 3000,
              productTitle: '풀무원 신선란 10구',
              purchaseLink: 'https://coupang.com',
              isChecked: true,
            ),
            ShoppingItem(
              itemId: 'item_002',
              ingredientId: 'I_002',
              ingredientName: '김치',
              standardUnit: '500g',
              deliveryType: 'rocket',
              lowestPrice: 3000,
              productTitle: '비비고 포기김치 500g',
              purchaseLink: 'https://coupang.com',
              isChecked: true,
            ),
          ],
        ),
        ShoppingMarketGroup(
          market: 'market_kurly',
          subtotal: 3000,
          items: const [
            ShoppingItem(
              itemId: 'item_003',
              ingredientId: 'I_003',
              ingredientName: '두부',
              standardUnit: '1모',
              deliveryType: 'normal',
              lowestPrice: 3000,
              productTitle: '풀무원 국산콩 두부',
              purchaseLink: 'https://kurly.com',
              isChecked: true,
            ),
          ],
        ),
        ShoppingMarketGroup(
          market: 'naver_shopping',
          subtotal: 3000,
          items: const [
            ShoppingItem(
              itemId: 'item_004',
              ingredientId: 'I_004',
              ingredientName: '대파',
              standardUnit: '1단',
              deliveryType: 'normal',
              lowestPrice: 3000,
              productTitle: '국내산 대파 1단',
              purchaseLink: 'https://shopping.naver.com',
              isChecked: true,
            ),
          ],
        ),
      ],
    );
  }
}