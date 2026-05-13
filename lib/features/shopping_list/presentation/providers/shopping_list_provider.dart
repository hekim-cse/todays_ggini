import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_client.dart';
import '../../data/shopping_list_repository.dart';
import '../../domain/shopping_list.dart';

// Repository Provider
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepository(ref.watch(dioProvider));
});

// State 클래스
class ShoppingListState {
  final ShoppingList? data;
  final bool isLoading;
  final Object? error;

  const ShoppingListState({this.data, this.isLoading = false, this.error});

  ShoppingListState copyWith({
    ShoppingList? data,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return ShoppingListState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier 클래스
class ShoppingListNotifier extends StateNotifier<ShoppingListState> {
  final ShoppingListRepository _repository;

  ShoppingListNotifier(this._repository) : super(const ShoppingListState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repository.fetchShoppingList();
      if (!mounted) return;
      state = ShoppingListState(data: data, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  // 사용자가 새로고침을 원할 때
  Future<void> refresh() => _load();

  // 항목 체크/해제. 백엔드 연동 전이므로 클라이언트에서 즉시 갱신
  // 추후 PATCH /shopping-list/items/{itemId} 응답의 summary 로 교체 예정
  void toggleItem(String itemId) {
    final current = state.data;
    if (current == null) return;

    final newGroups =
        current.marketGroups.map((group) {
          final newItems =
              group.items.map((item) {
                if (item.itemId != itemId) return item;
                return item.copyWith(isChecked: !item.isChecked);
              }).toList();
          return group.copyWith(items: newItems);
        }).toList();

    state = state.copyWith(data: _recomputeSummary(current, newGroups));
  }

  // 체크된 항목 일괄 삭제
  // 추후 DELETE /shopping-list/items 응답으로 받은 summary 로 교체 예정
  void deleteCheckedItems() {
    final current = state.data;
    if (current == null) return;

    final newGroups =
        current.marketGroups.map((group) {
          final remaining =
              group.items.where((item) => !item.isChecked).toList();
          return group.copyWith(items: remaining);
        }).toList();

    state = state.copyWith(data: _recomputeSummary(current, newGroups));
  }

  // market_groups 가 바뀐 후 상단 summary 필드들을 다시 계산
  // 백엔드 응답이 summary 를 같이 주면 이 함수는 필요 없어짐
  ShoppingList _recomputeSummary(
    ShoppingList current,
    List<ShoppingMarketGroup> newGroups,
  ) {
    int totalItems = 0;
    int checkedCount = 0;
    int totalPrice = 0;
    final newMarketCounts = <ShoppingMarketCount>[];
    final updatedGroups = <ShoppingMarketGroup>[];

    for (final group in newGroups) {
      int marketCheckedCount = 0;
      int marketSubtotal = 0;
      for (final item in group.items) {
        totalItems += 1;
        if (item.isChecked) {
          checkedCount += 1;
          totalPrice += item.lowestPrice;
          marketCheckedCount += 1;
          marketSubtotal += item.lowestPrice;
        }
      }
      newMarketCounts.add(
        ShoppingMarketCount(market: group.market, count: marketCheckedCount),
      );
      updatedGroups.add(group.copyWith(subtotal: marketSubtotal));
    }

    return current.copyWith(
      totalItems: totalItems,
      checkedItemsCount: checkedCount,
      totalPricePerShopping: totalPrice,
      marketCounts: newMarketCounts,
      marketGroups: updatedGroups,
    );
  }
}

// StateNotifierProvider
final shoppingListProvider =
    StateNotifierProvider.autoDispose<ShoppingListNotifier, ShoppingListState>(
      (ref) => ShoppingListNotifier(ref.watch(shoppingListRepositoryProvider)),
    );
