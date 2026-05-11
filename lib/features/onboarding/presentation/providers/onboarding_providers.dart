import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_client.dart';
import '../../data/onboarding_remote_data_source.dart';
import '../../data/onboarding_repository.dart';
import '../../domain/persona.dart';
import '../../domain/user_profile.dart';

// ─────────────────────────────────────────────────────────────
// Data layer providers
// ─────────────────────────────────────────────────────────────

final _onboardingRemoteProvider = Provider<OnboardingRemoteDataSource>((ref) {
  return OnboardingRemoteDataSource(ref.watch(dioProvider));
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(_onboardingRemoteProvider));
});

// ─────────────────────────────────────────────────────────────
// 선택된 페르소나
// ─────────────────────────────────────────────────────────────

final selectedPersonaProvider = StateProvider<Persona>((ref) {
  return Persona.singleValue;
});

// ─────────────────────────────────────────────────────────────
// 슬라이더 입력값 draft state
// ─────────────────────────────────────────────────────────────

class OnboardingDraft {
  const OnboardingDraft({
    this.goals = const [],
    this.foods = const [],
    this.ingredient = const [],
    this.allergies = const [],
    this.diversity = 2,
    this.cookingSkill = 3,
    this.mealCount = 3,
    this.monthlyBudget = 300000,
  });

  final List<String> goals;
  final List<String> foods;
  final List<String> ingredient;
  final List<String> allergies;
  final int diversity;
  final int cookingSkill;
  final int mealCount;
  final int monthlyBudget;

  OnboardingDraft copyWith({
    List<String>? goals,
    List<String>? foods,
    List<String>? ingredient,
    List<String>? allergies,
    int? diversity,
    int? cookingSkill,
    int? mealCount,
    int? monthlyBudget,
  }) {
    return OnboardingDraft(
      goals: goals ?? this.goals,
      foods: foods ?? this.foods,
      ingredient: ingredient ?? this.ingredient,
      allergies: allergies ?? this.allergies,
      diversity: diversity ?? this.diversity,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      mealCount: mealCount ?? this.mealCount,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingDraft> {
  OnboardingNotifier(this._repo, this._readPersona)
      : super(const OnboardingDraft());

  final OnboardingRepository _repo;
  final Persona Function() _readPersona;

  void setGoals(List<String> v) => state = state.copyWith(goals: v);
  void setFoods(List<String> v) => state = state.copyWith(foods: v);
  void setIngredient(List<String> v) => state = state.copyWith(ingredient: v);
  void setAllergies(List<String> v) => state = state.copyWith(allergies: v);
  void setDiversity(int v) => state = state.copyWith(diversity: v);
  void setCookingSkill(int v) => state = state.copyWith(cookingSkill: v);
  void setMealCount(int v) => state = state.copyWith(mealCount: v);
  void setMonthlyBudget(int v) => state = state.copyWith(monthlyBudget: v);

  Future<UserProfile> submit() async {
    final profile = UserProfile(
      persona: _readPersona(),
      goals: state.goals,
      foods: state.foods,
      ingredient: state.ingredient,
      allergies: state.allergies,
      diversity: state.diversity,
      cookingSkill: state.cookingSkill,
      mealCount: state.mealCount,
      monthlyBudget: state.monthlyBudget,
    );
    return _repo.saveProfile(profile);
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingDraft>((ref) {
  return OnboardingNotifier(
    ref.watch(onboardingRepositoryProvider),
    () => ref.read(selectedPersonaProvider),
  );
});

// ─────────────────────────────────────────────────────────────
// submit 결과
// ─────────────────────────────────────────────────────────────

final submitOnboardingProvider = StateProvider<AsyncValue<UserProfile>?>(
  (ref) => null,
);