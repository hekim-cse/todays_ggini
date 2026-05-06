from services.profile.weight_service import get_weights_by_goals
from utils.calculator import calculate_meal_budget


def get_diversity_penalty_strength(diversity_level: str) -> float:
    """
    메뉴 다양성 선택값을 감점 강도로 변환한다.

    낮음:
    - 메뉴 반복을 어느 정도 허용한다.
    - 그래도 완전 반복은 피하기 위해 약한 감점을 준다.

    보통:
    - 비슷한 메뉴가 반복되면 눈에 띄게 감점한다.

    높음:
    - 반복 메뉴를 싫어하는 사용자이므로 강하게 감점한다.
    """

    mapping = {
        "낮음": 0.2,
        "보통": 0.45,
        "높음": 0.65
    }

    return mapping.get(diversity_level, 0.45)


def build_user_profile(user_input) -> dict:
    """
    사용자가 선택한 값을 추천 계산에 사용할 수 있는 모델링 값으로 변환한다.
    """

    # 3일치 샘플 요청에는 period_days가 없을 수 있으므로 기본 30일 사용
    budget_period_days = user_input.period_days or 30

    meal_budget = calculate_meal_budget(
        monthly_budget=user_input.monthly_budget,
        meal_count_per_day=user_input.meal_count_per_day,
        budget_period_days=budget_period_days
    )

    weights = get_weights_by_goals(user_input.goals)

    profile = {
        "goals": user_input.goals,
        "budget_period_days": budget_period_days,
        "sample_period_days": user_input.sample_period_days,
        "period_days": user_input.period_days,
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