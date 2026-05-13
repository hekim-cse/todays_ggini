import 'package:flutter_riverpod/legacy.dart';

import '../../../home/data/home_repository.dart';
import '../../../home/domain/menu_detail.dart';
import '../../../home/presentation/providers/home_provider.dart';

// State 클래스
class IngredientListState {
  final MenuDetail? menu;
  final Set<String> checkedIngredientIds; // 체크된 재료의 ID 집합
  final bool excludeSecondary; // 부재료 제외 토글 (UI만, 동작 미구현)
  final bool isLoading;
  final Object? error;

  const IngredientListState({
    this.menu,
    this.checkedIngredientIds = const {},
    this.excludeSecondary = false,
    this.isLoading = false,
    this.error,
  });

  // 체크된 재료 개수 (하단 요약용)
  int get checkedCount => checkedIngredientIds.length;

  // 체크된 재료들의 합계 (최저가 기준)
  int get totalPrice {
    if (menu == null) return 0;
    return menu!.ingredients
        .where((i) => checkedIngredientIds.contains(i.ingredientId))
        .fold<int>(0, (sum, i) => sum + i.lowestPrice.price);
  }

  IngredientListState copyWith({
    MenuDetail? menu,
    Set<String>? checkedIngredientIds,
    bool? excludeSecondary,
    bool? isLoading,
    Object? error,
  }) {
    return IngredientListState(
      menu: menu ?? this.menu,
      checkedIngredientIds: checkedIngredientIds ?? this.checkedIngredientIds,
      excludeSecondary: excludeSecondary ?? this.excludeSecondary,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier 클래스
class IngredientListNotifier extends StateNotifier<IngredientListState> {
  final HomeRepository _repository;
  final String _mealId;

  IngredientListNotifier(this._repository, this._mealId)
    : super(const IngredientListState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final menu = await _repository.fetchMenuDetail(_mealId);
      if (!mounted) return;
      // 초기에는 모든 재료가 체크된 상태로 시작
      state = state.copyWith(
        menu: menu,
        checkedIngredientIds:
            menu.ingredients.map((i) => i.ingredientId).toSet(),
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  // 한 재료의 체크 상태 토글
  void toggleIngredient(String ingredientId) {
    final newSet = Set<String>.from(state.checkedIngredientIds);
    if (newSet.contains(ingredientId)) {
      newSet.remove(ingredientId);
    } else {
      newSet.add(ingredientId);
    }
    state = state.copyWith(checkedIngredientIds: newSet);
  }

  // 부재료 제외 토글 (UI만)
  void toggleExcludeSecondary() {
    state = state.copyWith(excludeSecondary: !state.excludeSecondary);
  }
}

// Provider — mealId별 family
// mealId마다 별도 인스턴스가 만들어지고 같은 mealId면 같은 인스턴스 재사용
final ingredientListProvider = StateNotifierProvider.autoDispose
    .family<IngredientListNotifier, IngredientListState, String>((ref, mealId) {
      final repository = ref.watch(homeRepositoryProvider);
      return IngredientListNotifier(repository, mealId);
    });
