import random
from copy import deepcopy

from services.style.meal_style_service import boost_style_weights
from services.recommendation.recommendation_service import recommend_menus
from services.plan.period_plan_service import build_period_meal_plan


def select_random_meal_style(meal_style_response: dict) -> dict:
    """
    스타일 후보 3개 중 하나를 랜덤으로 선택한다.

    실제 서비스에서는 사용자가 스타일을 직접 선택하지만,
    테스트 단계에서는 랜덤 선택으로 월간 식단 생성 흐름을 확인한다.
    """

    meal_style_candidates = meal_style_response.get("meal_style_candidates", [])

    if not meal_style_candidates:
        raise ValueError("선택할 식단 스타일 후보가 없습니다.")

    return random.choice(meal_style_candidates)


def build_profile_for_selected_style(
    profile: dict,
    selected_style: dict
) -> dict:
    """
    선택된 스타일의 focus_key를 기준으로 사용자 프로필의 weights를 조정한다.

    예:
    - 고단백 관리식 → nutrition 강화
    - 가성비 최우선 → budget 강화
    - 간편 조리식 → difficulty 강화
    """

    focus_key = selected_style.get("focus_key")

    if focus_key is None:
        raise ValueError("선택된 스타일에 focus_key가 없습니다.")

    style_weights = boost_style_weights(
        base_weights=profile["weights"],
        focus_key=focus_key,
        boost_amount=0.2
    )

    selected_style_profile = deepcopy(profile)
    selected_style_profile["weights"] = style_weights
    selected_style_profile["selected_style"] = {
        "style_id": selected_style.get("style_id"),
        "style_name": selected_style.get("style_name"),
        "focus_key": selected_style.get("focus_key"),
        "source_goal": selected_style.get("source_goal")
    }

    return selected_style_profile


def build_monthly_plan_by_random_style(
    user_id: str,
    candidate_menus: list[dict],
    profile: dict,
    meal_style_response: dict
) -> dict:
    """
    테스트용 월간 식단 생성 함수이다.

    흐름:
    1. 스타일 후보 3개 중 하나를 랜덤 선택한다.
    2. 선택된 스타일 기준으로 profile weights를 조정한다.
    3. 전체 기간 식단 생성을 위해 추천 메뉴를 다시 계산한다.
    4. build_weekly_meal_plan()으로 period_days 만큼 식단을 구성한다.
    """

    selected_style = select_random_meal_style(
        meal_style_response=meal_style_response
    )

    selected_style_profile = build_profile_for_selected_style(
        profile=profile,
        selected_style=selected_style
    )

    period_days = profile.get("period_days") or profile.get("budget_period_days") or 30
    meal_count_per_day = meal_style_response["meta"]["meal_count_per_day"]

    # 각 끼니마다 기본 메뉴 1개 + 대안 메뉴 2개가 필요하므로 3배수로 요청한다.
    required_candidate_count = period_days * meal_count_per_day * 3

    recommendations = recommend_menus(
        menus=candidate_menus,
        profile=selected_style_profile,
        top_n=required_candidate_count
    )

    monthly_plan = build_period_meal_plan(
        recommendations=recommendations,
        meal_count_per_day=meal_count_per_day,
        period_days=period_days,
        diversity_penalty_strength=selected_style_profile["diversity_penalty_strength"]
    )

    return {
        "user_id": user_id,
        "request_type": "monthly_meal_plan_test",
        "selected_style": {
            "style_id": selected_style.get("style_id"),
            "style_name": selected_style.get("style_name"),
            "description": selected_style.get("description"),
            "summary_comment": selected_style.get("summary_comment"),
            "source_goal": selected_style.get("source_goal"),
            "focus_key": selected_style.get("focus_key")
        },
        "meta": {
            "period_days": period_days,
            "meal_count_per_day": meal_count_per_day,
            "required_candidate_count": required_candidate_count,
            "actual_recommendation_count": len(recommendations)
        },
        "monthly_plan": monthly_plan
    }