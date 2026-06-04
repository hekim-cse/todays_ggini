import 'package:flutter_riverpod/legacy.dart';

import '../../../home/data/home_repository.dart';
import '../../../home/domain/menu_detail.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../shopping_selection/presentation/providers/shopping_selection_provider.dart';

// State 클래스 — 체크 상태는 shoppingSelectionProvider가 들고 있음
class IngredientListState {
  final MenuDetail? menu;
  final bool excludeSecondary;
  final bool isLoading;
  final Object? error;

  const IngredientListState({
    this.menu,
    this.excludeSecondary = false,
    this.isLoading = false,
    this.error,
  });

  IngredientListState copyWith({
    MenuDetail? menu,
    bool? excludeSecondary,
    bool? isLoading,
    Object? error,
  }) {
    return IngredientListState(
      menu: menu ?? this.menu,
      excludeSecondary: excludeSecondary ?? this.excludeSecondary,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 인자 record 타입 별칭 (가독성용)
typedef IngredientListArgs = ({String mealId, DateTime date, int slot});

class IngredientListNotifier extends StateNotifier<IngredientListState> {
  final HomeRepository _repository;
  final ShoppingSelectionNotifier _selectionNotifier;
  final String _mealId;
  final DateTime _date;
  final int _slot;

  IngredientListNotifier(
    this._repository,
    this._selectionNotifier,
    this._mealId,
    this._date,
    this._slot,
  ) : super(const IngredientListState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final menu = await _repository.fetchMenuDetail(
        mealDate: _date,
        mealId: _mealId,
      );
      if (!mounted) return;
      // 이 날짜+슬롯을 처음 보는 경우만 "모든 재료 체크" 초기화
      _selectionNotifier.initIfAbsent(
        _date,
        _slot,
        menu.ingredients.map((i) => i.ingredientId).toSet(),
      );
      state = state.copyWith(menu: menu, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  void toggleIngredient(String ingredientId) {
    _selectionNotifier.toggle(_date, _slot, ingredientId);
  }

  void toggleExcludeSecondary() {
    state = state.copyWith(excludeSecondary: !state.excludeSecondary);
  }
}

final ingredientListProvider = StateNotifierProvider.autoDispose
    .family<IngredientListNotifier, IngredientListState, IngredientListArgs>((
      ref,
      args,
    ) {
      final repository = ref.watch(homeRepositoryProvider);
      final selectionNotifier = ref.watch(shoppingSelectionProvider.notifier);
      return IngredientListNotifier(
        repository,
        selectionNotifier,
        args.mealId,
        args.date,
        args.slot,
      );
    });
