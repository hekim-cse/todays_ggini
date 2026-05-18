import 'persona.dart';

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

  final Persona persona;
  final List<String> goals;
  final List<String> foods;
  final List<String> ingredient;
  final List<String> allergies;
  final String diversity; // int → String ("낮음", "보통", "높음")
  final int cookingSkill;
  final int mealCount;
  final int monthlyBudget;

  Map<String, dynamic> toJson() => {
    'persona_id': persona.id, // int
    'purpose': goals,
    'preferred_categories': foods,
    'preferred_ingredients': ingredient,
    'excluded_ingredients': allergies,
    'diversity_level': diversity, // String
    'cooking_skill': cookingSkill,
    'meals_per_day': mealCount,
    'monthly_budget': monthlyBudget,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    persona: Persona.fromId(json['persona_id'] as int),
    goals: List<String>.from(json['purpose'] as List),
    foods: List<String>.from(json['preferred_categories'] as List),
    ingredient: List<String>.from(json['preferred_ingredients'] as List),
    allergies: List<String>.from(json['excluded_ingredients'] as List),
    diversity: json['diversity_level'] as String,
    cookingSkill: json['cooking_skill'] as int,
    mealCount: json['meals_per_day'] as int,
    monthlyBudget: json['monthly_budget'] as int,
  );

  UserProfile copyWith({
    Persona? persona,
    List<String>? goals,
    List<String>? foods,
    List<String>? ingredient,
    List<String>? allergies,
    String? diversity,
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
