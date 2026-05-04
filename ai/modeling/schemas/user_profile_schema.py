from pydantic import BaseModel, Field, field_validator
from typing import List, Optional


class UserProfileInput(BaseModel):
    """
    사용자가 개인 맞춤 설정 페이지에서 입력한 값을 담는 구조이다.

    sample_period_days:
    - 3일치 샘플 식단 생성에 사용한다.

    period_days:
    - 월간 식단 생성 기간에 사용한다.
    - 3일치 샘플 생성 단계에서는 없어도 된다.
    """

    goals: List[str] = Field(..., min_length=1, max_length=3)

    monthly_budget: int
    meal_count_per_day: int
    cooking_skill: int

    preferred_categories: List[str]
    diversity_level: str
    ingredient_preferences: List[str]
    allergy_ingredients: Optional[List[str]] = []

    # 샘플 식단 생성용
    sample_period_days: Optional[int] = 3

    # 월간 식단 생성용
    period_days: Optional[int] = None

    @field_validator("goals")
    @classmethod
    def validate_goals(cls, goals: List[str]) -> List[str]:
        allowed_goals = [
            "식비 절약",
            "영양 균형",
            "다이어트",
            "고단백",
            "간편식",
            "맛 중심",
        ]

        if len(goals) != len(set(goals)):
            raise ValueError("목표는 중복 없이 선택해야 합니다.")

        for goal in goals:
            if goal not in allowed_goals:
                raise ValueError(f"지원하지 않는 목표입니다: {goal}")

        return goals

    @field_validator("ingredient_preferences")
    @classmethod
    def validate_ingredient_preferences(
        cls,
        ingredient_preferences: List[str]
    ) -> List[str]:
        allowed_ingredient_groups = [
            "육류",
            "해산물류",
            "식물성 단백질류",
            "채소류",
            "계란·유제품류",
            "곡류",
        ]

        if len(ingredient_preferences) != len(set(ingredient_preferences)):
            raise ValueError("선호 재료군은 중복 없이 선택해야 합니다.")

        for ingredient_group in ingredient_preferences:
            if ingredient_group not in allowed_ingredient_groups:
                raise ValueError(
                    f"지원하지 않는 재료군입니다: {ingredient_group}"
                )

        return ingredient_preferences