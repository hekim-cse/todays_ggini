import 'persona.dart';

/// 온보딩 슬라이더로 입력받는 사용자 프로필.
/// OpenAPI `UserProfile` 스키마와 1:1 매핑.
class UserProfile {
  const UserProfile({
    required this.persona,
    required this.goals,
    required this.foods,
    required this.ingredient,
    required this.allergies,
    required this.diversity,
    required this.cookingSkill,
    required this.mealCount,
    required this.monthlyBudget,
  });


  /// 페르소나 (가성비 자취생 등)
  final Persona persona;

  /// 목적 (식비절약, 영양균형, 다이어트 등 복수 선택)
  final List<String> goals;

  /// 취향 (한식, 중식, 일식 등 복수 선택)
  final List<String> foods;

  /// 식재료 (육류, 채소류 등 복수 선택)
  final List<String> ingredient;

  /// 알레르기 및 제외 재료 (복수 선택)
  final List<String> allergies;

  /// 다양성 (1~3)
  final int diversity;

  /// 요리실력 (1~5)
  final int cookingSkill;

  /// 하루 식사 수 (1~5)
  final int mealCount;

  /// 한달 식비 예산 KRW (100,000 ~ 1,000,000)
  final int monthlyBudget;

  Map<String, dynamic> toJson() => {
    'persona': persona.code,
    'goals': goals,
    'foods': foods,
    'ingredient': ingredient,
    'allergies': allergies,
    'diversity': diversity,
    'cookingSkill': cookingSkill,
    'mealCount': mealCount,
    'monthlyBudget': monthlyBudget,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    persona: Persona.fromCode(json['persona'] as String),
    goals: List<String>.from(json['goals'] as List),
    foods: List<String>.from(json['foods'] as List),
    ingredient: List<String>.from(json['ingredient'] as List),
    allergies: List<String>.from(json['allergies'] as List),
    diversity: json['diversity'] as int,
    cookingSkill: json['cookingSkill'] as int,
    mealCount: json['mealCount'] as int,
    monthlyBudget: json['monthlyBudget'] as int,
  );

  UserProfile copyWith({
    Persona? persona,
    List<String>? goals,
    List<String>? foods,
    List<String>? ingredient,
    List<String>? allergies,
    int? diversity,
    int? cookingSkill,
    int? mealCount,
    int? monthlyBudget,
  }) {
    return UserProfile(
      persona: persona ?? this.persona,
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
