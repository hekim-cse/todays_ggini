import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_client.dart';
import '../../../home/domain/daily_meal_plan.dart';
import '../../data/menu_change_repository.dart';
import '../../domain/menu_alternatives.dart';

// Repository Provider
final menuChangeRepositoryProvider = Provider<MenuChangeRepository>((ref) {
  return MenuChangeRepository(ref.watch(dioProvider));
});

/// family 인자. ingredient_list 와 같은 패턴
typedef MenuChangeArgs = ({String mealId, DateTime date, int slot});

// State 클래스
class MenuChangeState {
  final MenuAlternatives? data;
  final bool isLoading;
  final bool isChanging; // PUT 진행 중 (버튼 비활성 표시용)
  final Object? error;

  const MenuChangeState({
    this.data,
    this.isLoading = false,
    this.isChanging = false,
    this.error,
  });

  MenuChangeState copyWith({
    MenuAlternatives? data,
    bool? isLoading,
    bool? isChanging,
    Object? error,
    bool clearError = false,
  }) {
    return MenuChangeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isChanging: isChanging ?? this.isChanging,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier 클래스
class MenuChangeNotifier extends StateNotifier<MenuChangeState> {
  final MenuChangeRepository _repository;
  final String _mealId;
  final DateTime _date;
  final int _slot;

  MenuChangeNotifier(this._repository, this._mealId, this._date, this._slot)
    : super(const MenuChangeState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _repository.fetchAlternatives(
        currentMealId: _mealId,
        targetDate: _date,
      );
      if (!mounted) return;
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  // 메뉴 변경 실행
  //
  // PUT mock 이 어떤 slot/meal_id 를 보내도 같은 응답을 돌려주는 한계 때문에,
  // 새 plan 은 [currentPlan] 과 [chosenAlternative] 를 바탕으로 **클라이언트에서**
  // 만든다. mock 응답 자체는 호출은 하되 무시. 백엔드 연동 시에는 응답을
  // 신뢰하도록 전환 (TODO 참고)
  //
  // 성공 시 갱신된 [DailyMealPlan] 반환 — 화면에서 받아 mealDetailProvider 에 반영
  // 실패 시 null 반환하고 state.error 채움
  Future<DailyMealPlan?> applyChange({
    required DailyMealPlan currentPlan,
    required AlternativeMeal chosenAlternative,
  }) async {
    state = state.copyWith(isChanging: true, clearError: true);
    try {
      // mock 모드: 호출은 하되 응답 무시 (mock 한계)
      // 실서버 모드: 응답을 신뢰하고 그걸 반환하도록 바꿔야 함
      await _repository.changeMenu(
        date: _date,
        slot: _slot,
        newMenuId: chosenAlternative.mealId,
      );
      if (!mounted) return null;

      final newPlan = _buildLocalPlan(currentPlan, chosenAlternative);
      state = state.copyWith(isChanging: false);
      return newPlan;
    } catch (e) {
      if (!mounted) return null;
      state = state.copyWith(isChanging: false, error: e);
      return null;
    }
  }

  // 현재 plan 에서 [_slot] 만 [alt] 로 교체한 새 [DailyMealPlan] 을 만들기
  // 일일 칼로리/가격은 합산하여 재계산
  DailyMealPlan _buildLocalPlan(DailyMealPlan current, AlternativeMeal alt) {
    final newSlotMeal = MealSlotSummary(
      slot: _slot,
      mealId: alt.mealId,
      menuName: alt.menuName,
      calories: alt.calories,
      price: alt.price,
      imageUrl: alt.imageUrl,
    );
    final newMeals =
        current.meals.map((m) => m.slot == _slot ? newSlotMeal : m).toList();
    final newCalories = newMeals.fold<int>(0, (sum, m) => sum + m.calories);
    final newPrice = newMeals.fold<int>(0, (sum, m) => sum + m.price);
    return DailyMealPlan(
      date: current.date,
      caloriesPerDay: newCalories,
      pricePerDay: newPrice,
      meals: newMeals,
    );
  }
}

// StateNotifierProvider.family
final menuChangeProvider = StateNotifierProvider.autoDispose
    .family<MenuChangeNotifier, MenuChangeState, MenuChangeArgs>((ref, args) {
      final repository = ref.watch(menuChangeRepositoryProvider);
      return MenuChangeNotifier(repository, args.mealId, args.date, args.slot);
    });
