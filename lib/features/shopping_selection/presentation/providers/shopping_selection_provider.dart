import 'package:flutter_riverpod/legacy.dart';

import '../../../home/data/home_repository.dart';
import '../../../home/domain/daily_meal_plan.dart';
import '../../../shopping_list/data/shopping_list_repository.dart';
import '../../../shopping_list/domain/shopping_item_request.dart';

/// 사용자의 장보기 선택 상태.
///
/// 두 가지 정보를 들고 있음:
/// 1. selectionsByDateSlot: 날짜+슬롯별 체크된 재료들
///    "2026-04-06:1" → {"I_004", "I_005"}  (4/6 1번 슬롯의 양파, 당근만 체크)
/// 2. selectedMarketByIngredient: 재료별 선택한 마켓 (날짜 무관)
///    "I_001" → "market_kurly"  (제철 나물은 항상 컬리에서 살래)
///
/// 둘 다 autoDispose 없음 — 앱 살아있는 동안 유지.
class ShoppingSelectionState {
  final Map<String, Set<String>> selectionsByDateSlot;
  final Map<String, String> selectedMarketByIngredient;

  const ShoppingSelectionState({
    this.selectionsByDateSlot = const {},
    this.selectedMarketByIngredient = const {},
  });

  /// 헬퍼: date + slot → 키 문자열.
  /// 예: (DateTime(2026, 4, 6), 1) → "2026-04-06:1"
  static String makeKey(DateTime date, int slot) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d:$slot';
  }

  /// 특정 날짜+슬롯에서 체크된 재료들.
  Set<String>? selectionFor(DateTime date, int slot) =>
      selectionsByDateSlot[makeKey(date, slot)];

  /// 특정 날짜+슬롯의 특정 재료가 체크돼있는지.
  bool isChecked(DateTime date, int slot, String ingredientId) {
    final set = selectionsByDateSlot[makeKey(date, slot)];
    return set?.contains(ingredientId) ?? false;
  }

  /// 특정 재료에 사용자가 선택한 마켓. 없으면 null (디폴트는 최저가 사용).
  String? selectedMarketFor(String ingredientId) =>
      selectedMarketByIngredient[ingredientId];

  ShoppingSelectionState copyWith({
    Map<String, Set<String>>? selectionsByDateSlot,
    Map<String, String>? selectedMarketByIngredient,
  }) {
    return ShoppingSelectionState(
      selectionsByDateSlot: selectionsByDateSlot ?? this.selectionsByDateSlot,
      selectedMarketByIngredient:
          selectedMarketByIngredient ?? this.selectedMarketByIngredient,
    );
  }
}

class ShoppingSelectionNotifier extends StateNotifier<ShoppingSelectionState> {
  ShoppingSelectionNotifier() : super(const ShoppingSelectionState());

  /// 한 날짜+슬롯의 재료 선택 상태를 초기화 (이미 있으면 건드리지 않음).
  void initIfAbsent(DateTime date, int slot, Set<String> defaultIds) {
    final key = ShoppingSelectionState.makeKey(date, slot);
    if (state.selectionsByDateSlot.containsKey(key)) return;
    final newMap = Map<String, Set<String>>.from(state.selectionsByDateSlot);
    newMap[key] = defaultIds;
    state = state.copyWith(selectionsByDateSlot: newMap);
  }

  /// 특정 날짜+슬롯의 특정 재료 체크 상태 토글.
  void toggle(DateTime date, int slot, String ingredientId) {
    final key = ShoppingSelectionState.makeKey(date, slot);
    final currentSet = state.selectionsByDateSlot[key] ?? <String>{};
    final newSet = Set<String>.from(currentSet);
    if (newSet.contains(ingredientId)) {
      newSet.remove(ingredientId);
    } else {
      newSet.add(ingredientId);
    }
    final newMap = Map<String, Set<String>>.from(state.selectionsByDateSlot);
    newMap[key] = newSet;
    state = state.copyWith(selectionsByDateSlot: newMap);
  }

  /// 재료의 마켓 선택. 같은 마켓 다시 누르면 선택 해제(디폴트로 복귀).
  void selectMarket(String ingredientId, String market) {
    final newMap = Map<String, String>.from(state.selectedMarketByIngredient);
    if (newMap[ingredientId] == market) {
      newMap.remove(ingredientId);
    } else {
      newMap[ingredientId] = market;
    }
    state = state.copyWith(selectedMarketByIngredient: newMap);
  }

  /// "이 날 장보기 목록 추가" 흐름 전체.
  ///
  /// 1) 각 slot 의 menuDetail 을 병렬 fetch
  /// 2) 슬롯별로 selection state 확인:
  ///    - selection 있으면 사용자가 체크한 재료만 payload 에 포함
  ///    - selection 없으면 모든 재료 포함 (기본값)
  /// 3) 각 재료의 마켓 결정:
  ///    - 사용자가 마켓 골랐으면 그 마켓 (재고 없으면 최저가로 fallback)
  ///    - 안 골랐으면 최저가 마켓
  /// 4) 모든 마켓에서 재고 없는 재료는 스킵 (payload 못 만듦)
  /// 5) POST /shopping/add-shopping-items
  ///
  /// 결과: 추가 개수 + 스킵된 재료 이름 목록 + 에러 정보.
  /// 위젯이 결과 받아서 스낵바/navigation 처리.
  Future<AddShoppingResult> submitToShoppingList({
    required DateTime date,
    required List<MealSlotSummary> meals,
    required HomeRepository homeRepo,
    required ShoppingListRepository shoppingRepo,
  }) async {
    try {
      // 1) 슬롯별 menuDetail 병렬 fetch
      final details = await Future.wait(
        meals.map(
          (m) => homeRepo.fetchMenuDetail(mealDate: date, mealId: m.mealId),
        ),
      );

      // 2~4) payload 구성
      final payload = <ShoppingItemRequest>[];
      final skipped = <String>[];

      for (int i = 0; i < meals.length; i++) {
        final meal = meals[i];
        final detail = details[i];

        final selectionKey = ShoppingSelectionState.makeKey(date, meal.slot);
        final userSelection = state.selectionsByDateSlot[selectionKey];

        for (final ing in detail.ingredients) {
          // selection 있는데 이 재료가 체크 안 됐으면 skip
          if (userSelection != null &&
              !userSelection.contains(ing.ingredientId)) {
            continue;
          }

          // 어떤 마켓도 재고 없으면 skip
          if (!ing.hasAnyMarketStock) {
            skipped.add(ing.ingredientName);
            continue;
          }

          // 사용자 선택 마켓 또는 최저가 마켓
          final userMarket = state.selectedMarketByIngredient[ing.ingredientId];
          final marketName = ing.effectiveMarket(userMarket);

          payload.add(
            ShoppingItemRequest(
              ingredientId: ing.ingredientId,
              marketName: marketName,
            ),
          );
        }
      }

      if (payload.isEmpty) {
        return AddShoppingResult(
          addedCount: 0,
          skippedIngredientNames: skipped,
        );
      }

      // 5) POST
      await shoppingRepo.addShoppingItems(payload);

      return AddShoppingResult(
        addedCount: payload.length,
        skippedIngredientNames: skipped,
      );
    } catch (e) {
      return AddShoppingResult(
        addedCount: 0,
        skippedIngredientNames: const [],
        error: e,
      );
    }
  }
}

final shoppingSelectionProvider =
    StateNotifierProvider<ShoppingSelectionNotifier, ShoppingSelectionState>(
      (ref) => ShoppingSelectionNotifier(),
    );
