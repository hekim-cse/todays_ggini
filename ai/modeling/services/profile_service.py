from services.weight_service import get_weights_by_goal
from utils.calculator import calculate_meal_budget


def get_diversity_penalty_strength(diversity_level: str) -> float:
    """
    메뉴 다양성 선택값을 감점 강도로 변환한다.

    낮음: 비슷한 메뉴가 반복되어도 괜찮으므로 감점 약함
    보통: 기본 감점
    높음: 반복 메뉴를 싫어하므로 감점 강함
    """

    mapping = {
        "낮음": 0.1,
        "보통": 0.3,
        "높음": 0.5
    }

    return mapping.get(diversity_level, 0.3)


def build_user_profile(user_input) -> dict:
    """
    사용자가 선택한 값을 추천 계산에 사용할 수 있는 모델링 값으로 변환한다.
    """

    meal_budget = calculate_meal_budget(
        monthly_budget=user_input.monthly_budget,
        meal_count_per_day=user_input.meal_count_per_day,
        year=user_input.year,
        month=user_input.month
    )

    weights = get_weights_by_goal(user_input.goal)

    profile = {
        "goal": user_input.goal,
        "year": user_input.year,
        "month": user_input.month,
        "meal_budget": meal_budget,
        "weights": weights,
        "max_difficulty": user_input.cooking_skill,
        "preferred_categories": user_input.preferred_categories,
        "ingredient_preferences": user_input.ingredient_preferences,
        "diversity_penalty_strength": get_diversity_penalty_strength(
            user_input.diversity_level
        ),
        "allergy_ingredients": user_input.allergy_ingredients
    }

    return profile