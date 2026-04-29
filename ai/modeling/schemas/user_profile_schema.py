from pydantic import BaseModel, Field, field_validator
from typing import List, Dict, Optional


class UserProfileInput(BaseModel):
    """
    사용자가 개인 맞춤 설정 페이지에서 입력한 값을 담는 구조이다.
    """

    # 목표는 최소 1개, 최대 3개까지 선택 가능
    goals: List[str] = Field(..., min_length=1, max_length=3)

    year: int
    month: int
    monthly_budget: int
    meal_count_per_day: int
    cooking_skill: int
    preferred_categories: List[str]
    diversity_level: str
    ingredient_preferences: Dict[str, int]
    allergy_ingredients: Optional[List[str]] = []

    @field_validator("goals")
    @classmethod
    def validate_goals(cls, goals: List[str]) -> List[str]:
        """
        목표 선택값이 허용된 목표인지, 중복은 없는지 확인한다.
        """

        allowed_goals = [
            "식비 절약",
            "영양 균형",
            "다이어트",
            "고단백",
            "간편식",
            "맛 중심",
        ]

        # 같은 목표를 중복 선택하지 못하게 막는다.
        if len(goals) != len(set(goals)):
            raise ValueError("목표는 중복 없이 선택해야 합니다.")

        # 정의되지 않은 목표가 들어오지 못하게 막는다.
        for goal in goals:
            if goal not in allowed_goals:
                raise ValueError(f"지원하지 않는 목표입니다: {goal}")

        return goals