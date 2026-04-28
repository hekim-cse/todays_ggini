from pydantic import BaseModel
from typing import List, Dict, Optional


class UserProfileInput(BaseModel):
    """
    사용자가 개인 맞춤 설정 페이지에서 입력한 값을 담는 구조이다.
    """

    goal: str
    year: int
    month: int
    monthly_budget: int
    meal_count_per_day: int
    cooking_skill: int
    preferred_categories: List[str]
    diversity_level: str
    ingredient_preferences: Dict[str, int]
    allergy_ingredients: Optional[List[str]] = []