from services.profile.weight_service import get_weights_by_goals
from schemas.user_profile_schema import UserProfileInput, UserProfileRequest
from utils.calculator import calculate_meal_budget


def get_diversity_penalty_strength(diversity_level: str) -> float:
    """
    메뉴 다양성 선택값을 감점 강도로 변환한다.
    """

    mapping = {
        "낮음": 0.2,
        "보통": 0.45,
        "높음": 0.65
    }

    return mapping.get(diversity_level, 0.45)


def build_user_profile(user_input: UserProfileInput) -> dict:
    """
    사용자가 선택한 값을 추천 계산에 사용할 수 있는 모델링 profile로 변환한다.

    원본 사용자 입력값은 최대한 유지하고,
    Modeling 계산에 필요한 값만 추가한다.
    """

    budget_period_days = user_input.period_days or 30
    period_days = user_input.period_days or budget_period_days

    meal_budget = calculate_meal_budget(
        monthly_budget=user_input.monthly_budget,
        meal_count_per_day=user_input.meal_count_per_day,
        budget_period_days=budget_period_days
    )

    weights = get_weights_by_goals(user_input.goals)

    return {
        # 원본 사용자 입력값 유지
        "goals": user_input.goals,
        "monthly_budget": user_input.monthly_budget,
        "meal_count_per_day": user_input.meal_count_per_day,
        "cooking_skill": user_input.cooking_skill,
        "preferred_categories": user_input.preferred_categories,
        "diversity_level": user_input.diversity_level,
        "ingredient_preferences": user_input.ingredient_preferences,
        "allergy_ingredients": user_input.allergy_ingredients,
        "sample_period_days": user_input.sample_period_days,
        "period_days": period_days,

        # Modeling 계산용 값 추가
        "budget_period_days": budget_period_days,
        "meal_budget": meal_budget,
        "weights": weights,
        "max_difficulty": user_input.cooking_skill,
        "diversity_penalty_strength": get_diversity_penalty_strength(
            user_input.diversity_level
        )
    }


def build_user_profile_response(request_data: dict) -> dict:
    """
    Back에서 Modeling으로 전달한 요청 JSON을 받아
    user_id와 모델링용 profile을 함께 묶어 반환한다.

    입력 예:
    {
      "user_id": "user_004",
      "request_type": "meal_style_candidates",
      "profile": {...}
    }

    출력 예:
    {
      "user_id": "user_004",
      "request_type": "profile_build",
      "profile": {...}
    }
    """

    request = UserProfileRequest(**request_data)

    profile = build_user_profile(request.profile)

    return {
        "user_id": request.user_id,
        "request_type": "profile_build",
        "profile": profile
    }