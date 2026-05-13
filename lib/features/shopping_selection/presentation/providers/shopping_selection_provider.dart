import 'package:flutter_riverpod/legacy.dart';

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
}

final shoppingSelectionProvider =
    StateNotifierProvider<ShoppingSelectionNotifier, ShoppingSelectionState>(
      (ref) => ShoppingSelectionNotifier(),
    );
