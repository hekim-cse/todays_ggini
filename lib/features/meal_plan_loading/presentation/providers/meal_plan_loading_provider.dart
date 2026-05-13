import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/meal_plan_loading_repository.dart';
import '../../domain/meal_plan_job.dart';
import '../../../../core/network/api_client.dart'; // dioProvider 정의

// Repository Provider: Provider<Repository 클래스>
// 앱 전역에서 사용하는 dioProvider를 가져와
// Dio 객체를 주입해 Repository 객체를 생성
final mealPlanLoadingRepositoryProvider = Provider<MealPlanLoadingRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return MealPlanLoadingRepository(dio);
});

// State 클래스
class MealPlanLoadingState {
  final MealPlanJob? job; // API 응답 (받기 전 null, 받은 후로는 고정)
  final int completedStages; // 0..stages.length (단계마다 증가)
  final bool isComplete; // 다음 화면으로 이동 트리거
  final Object? error; // 에러 없으면 null

  const MealPlanLoadingState({
    this.job,
    this.completedStages = 0,
    this.isComplete = false,
    this.error,
  });

  // 기존 값을 베이스로 인자로 받은 것만 바꾼 새 상태
  MealPlanLoadingState copyWith({
    MealPlanJob? job,
    int? completedStages,
    bool? isComplete,
    Object? error,
  }) {
    return MealPlanLoadingState(
      // 인자로 받은 바뀐 값이면 ?? 왼쪽으로, 인자를 받지 않은 null이면 오른쪽으로
      job: job ?? this.job,
      completedStages: completedStages ?? this.completedStages,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

// Notifier 클래스: StateNotifier<State 클래스> 상속
// 화면의 비즈니스 로직(API 호출, 단계별 진행)을 담당
// state 변수와 mounted 변수를 사용 가능
class MealPlanLoadingNotifier extends StateNotifier<MealPlanLoadingState> {
  final MealPlanLoadingRepository _repository;

  MealPlanLoadingNotifier(this._repository)
    : super(const MealPlanLoadingState()) {
    _start();
  }

  Future<void> _start() async {
    try {
      final job =
          await _repository.generateMealPlan(); // API 호출 → Domain 객체로 받음
      if (!mounted) return;
      state = state.copyWith(job: job); // 응답받은 Domain 객체만 갈아끼워 저장

      // estimated_seconds를 stages 개수로 나눠서 한 단계씩 진행
      final stepMs = (job.estimatedSeconds * 1000) ~/ job.stages.length;
      for (var i = 0; i < job.stages.length; i++) {
        await Future.delayed(Duration(milliseconds: stepMs));
        if (!mounted) return;
        state = state.copyWith(completedStages: i + 1);
      }
      state = state.copyWith(isComplete: true);
    } catch (e) {
      if (!mounted) return; // Notifier가 dispose되면 종료
      state = state.copyWith(error: e);
    }
  }
}

// StateNotifierProvider: Notifier가 State를 관리함을 명시
// StateNotifierProvider.autoDispose<Notifier 클래스, State 클래스>
// autoDispose: 화면 떠나면 Notifier도 정리되어 다음 진입 시 처음부터 다시 시작
final mealPlanLoadingProvider = StateNotifierProvider.autoDispose<
  MealPlanLoadingNotifier,
  MealPlanLoadingState
>(
  (ref) =>
      MealPlanLoadingNotifier(ref.watch(mealPlanLoadingRepositoryProvider)),
);
