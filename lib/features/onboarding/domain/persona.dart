/// 4가지 페르소나 (피그마: 가성비 자취생 / 우리가족 영양사 / 내 몸이 곧 재산 / 퇴근 후 맥주한잔)
///
/// `code` 는 OpenAPI enum 그대로 (서버 ↔ 클라이언트 통신용).
/// `label` 은 UI 표시용 한국어.
enum Persona {
  singleValue('single_value', '가성비 자취생', 1),
  familyNutrition('family_nutrition', '우리가족 영양사', 2),
  bodyProfile('body_profile', '내 몸이 곧 재산', 3),
  salaryBeer('salary_beer', '퇴근 후 맥주한잔', 4);

  const Persona(this.code, this.label, this.id);

  final String code;
  final String label;
  final int id;

  static Persona fromCode(String code) {
    return Persona.values.firstWhere(
      (p) => p.code == code,
      orElse: () => Persona.singleValue,
    );
  }

  static Persona fromId(int id) {
    return Persona.values.firstWhere(
      (p) => p.id == id,
      orElse: () => Persona.singleValue,
    );
  }
}