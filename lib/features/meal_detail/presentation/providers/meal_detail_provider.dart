import 'package:flutter_riverpod/legacy.dart';

import '../../../home/data/home_repository.dart';
import '../../../home/domain/daily_meal_plan.dart';
import '../../../home/presentation/providers/home_provider.dart';

// HomeRepository 및 homeRepositoryProvider 재사용

// State 클래스
class MealDetailState {
  final DailyMealPlan? plan;
  final bool isLoading;
  final Object? error;

  const MealDetailState({this.plan, this.isLoading = false, this.error});

  // 식단이 있는 날인지 (UI 분기용)
  bool get hasMealPlan => plan != null && plan!.meals.isNotEmpty;

  MealDetailState copyWith({
    DailyMealPlan? plan,
    bool? isLoading,
    Object? error,
  }) {
    return MealDetailState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier 클래스
class MealDetailNotifier extends StateNotifier<MealDetailState> {
  final HomeRepository _repository;
  final DateTime _date;

  MealDetailNotifier(this._repository, this._date)
    // family로 매번 새 인스턴스가 만들어지면서 바로 _load() 호출
    // 초기 상태가 사실상 항상 로딩 중
    : super(const MealDetailState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final plan = await _repository.fetchDailyMealPlan(_date);
      if (!mounted) return;
      state = state.copyWith(plan: plan, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  // 외부(예: menu_change 화면)에서 받은 새 [DailyMealPlan] 으로 state 교체
  // PUT /meal-plans/{date}/menus/{slot} 응답을 그대로 반영할 때 사용
  void replaceWith(DailyMealPlan newPlan) {
    if (!mounted) return;
    state = state.copyWith(plan: newPlan, isLoading: false);
  }
}

// StateNotifierProvider.family — 인자별 인스턴스
// date마다 별도 인스턴스가 만들어지고 같은 date면 같은 인스턴스 재사용
// ref.watch(mealDetailProvider(DateTime(2026, 4, 1)));  // 4/1용 인스턴스
// ref.watch(mealDetailProvider(DateTime(2026, 4, 2)));  // 4/2용 인스턴스 (별도)
// ref.watch(mealDetailProvider(DateTime(2026, 4, 1)));  // 4/1 다시 → 같은 인스턴스
final mealDetailProvider = StateNotifierProvider.autoDispose
    .family<MealDetailNotifier, MealDetailState, DateTime>((ref, date) {
      final repository = ref.watch(homeRepositoryProvider);
      return MealDetailNotifier(repository, date);
    });
