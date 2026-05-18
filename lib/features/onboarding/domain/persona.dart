/// 4가지 페르소나 (피그마: 가성비 자취생 / 우리가족 영양사 / 내 몸이 곧 재산 / 퇴근 후 맥주한잔)
///
/// `code` 는 OpenAPI enum 그대로 (서버 ↔ 클라이언트 통신용).
/// `label` 은 UI 표시용 한국어.
enum Persona {
  singleValue('single_value', '가성비 자취생'),
  familyNutrition('family_nutrition', '우리가족 영양사'),
  bodyProfile('body_profile', '내 몸이 곧 재산'),
  salaryBeer('salary_beer', '퇴근 후 맥주한잔');

  const Persona(this.code, this.label);

  final String code;
  final String label;

  /// 백엔드 persona_id (1~6 정수). 백엔드 스키마와 매핑.
  int get id {
    switch (this) {
      case Persona.singleValue:
        return 1;
      case Persona.familyNutrition:
        return 2;
      case Persona.bodyProfile:
        return 3;
      case Persona.salaryBeer:
        return 4;
    }
  }

  static Persona fromCode(String code) {
    return Persona.values.firstWhere(
      (p) => p.code == code,
      orElse: () => Persona.singleValue,
    );
  }
}
