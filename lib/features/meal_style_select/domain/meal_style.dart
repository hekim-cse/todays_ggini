class MealStyle {
  final String tag;
  final List<String> meals;
  final Map<String, int> stats;
  final String desc;
  final String emoji;

  const MealStyle({
    required this.tag,
    required this.meals,
    required this.stats,
    required this.desc,
    required this.emoji,
  });
}

final List<MealStyle> mockMealStyles = [
  MealStyle(
    tag: '가성비 최우선',
    meals: ['계란 볶음밥', '김치볶음밥', '제철 나물 비빔밥'],
    stats: {'건강': 1, '가성비': 9, '맛': 4, '조리': 6},
    desc: '가성비 자취생에게 추천!',
    emoji: '🐹',
  ),
  MealStyle(
    tag: '맛과 밸런스',
    meals: ['닭갈비 정식', '차돌 된장찌개', '불고기 덮밥'],
    stats: {'건강': 6, '가성비': 5, '맛': 9, '조리': 5},
    desc: '골고루 고려한 식단!',
    emoji: '🐹',
  ),
  MealStyle(
    tag: '건강/바디프로필',
    meals: ['닭가슴살 샐러드', '현미밥&생선구이', '곤약면 파스타'],
    stats: {'건강': 9, '가성비': 2, '맛': 5, '조리': 8},
    desc: '운동러에게 추천!',
    emoji: '🐹',
  ),
];