import random
from copy import deepcopy

from services.recommendation.recommendation_service import recommend_menus

from services.plan.menu_similarity_service import (
    get_recent_exposed_menus,
)

from services.plan.meal_selector_service import (
    increase_used_menu_count,
    select_alternative_menus,
    select_menu_for_meal,
)

from services.plan.plan_summary_service import (
    calculate_day_total_calories,
    calculate_day_total_estimated_cost,
    calculate_monthly_plan_summary,
)

from services.plan.plan_validation_service import (
    build_style_validation,
    enrich_style_validation,
)

from services.plan.plan_payload_service import (
    build_modeling_to_back_monthly_response,
)


def get_recent_day_window(diversity_penalty_strength: float) -> int:
    """
    다양성 강도에 따라 최근 며칠의 메뉴 반복을 피할지 결정한다.
    """

    if diversity_penalty_strength <= 0.1:
        return 0

    if diversity_penalty_strength <= 0.3:
        return 1

    return 2



def build_selected_style_summary(selected_style: dict) -> dict:
    """
    월간 식단 결과에 포함할 선택 스타일 요약 정보를 만든다.
    """

    return {
        "style_id": selected_style.get("style_id"),
        "style_name": selected_style.get("style_name"),
        "description": selected_style.get("description"),
        "summary_comment": selected_style.get("summary_comment"),
        "source_goal": selected_style.get("source_goal"),
        "focus_key": selected_style.get("focus_key"),
        "display_scores": selected_style.get("display_scores", {}),
        "display_labels": selected_style.get("display_labels", {}),
    }


def normalize_weights(weights: dict) -> dict:
    """
    가중치 합이 1이 되도록 정규화한다.
    """

    total = sum(weights.values())

    if total == 0:
        raise ValueError("가중치 합이 0입니다.")

    return {
        key: round(value / total, 4)
        for key, value in weights.items()
    }


def get_nutrition_detail_weights_by_style(selected_style: dict) -> dict:
    """
    사용자가 선택한 스타일에 따라 nutrition 내부 세부 가중치를 만든다.

    nutrition 점수는 하나의 점수처럼 보이지만,
    내부적으로는 다음 세부 기준으로 나뉜다.

    - diet: 칼로리와 지방 중심
    - high_protein: 단백질 중심
    - balance: 탄수화물/단백질/지방 비율 중심
    """

    source_goal = selected_style.get("source_goal")

    if source_goal == "다이어트":
        return {
            "diet": 0.75,
            "high_protein": 0.10,
            "balance": 0.15,
        }

    if source_goal == "고단백":
        return {
            "diet": 0.15,
            "high_protein": 0.65,
            "balance": 0.20,
        }

    if source_goal == "영양 균형":
        return {
            "diet": 0.20,
            "high_protein": 0.20,
            "balance": 0.60,
        }

    return {
        "diet": 0.33,
        "high_protein": 0.34,
        "balance": 0.33,
    }


def apply_selected_style_to_profile(
    profile: dict,
    selected_style: dict
) -> dict:
    """
    사용자가 선택한 3일 샘플 스타일을 월간 식단 생성용 profile에 반영한다.
    """

    monthly_profile = deepcopy(profile)

    monthly_profile["selected_style_goal"] = selected_style.get("source_goal")
    monthly_profile["selected_style_id"] = selected_style.get("style_id")
    monthly_profile["selected_style_focus_key"] = selected_style.get("focus_key")

    focus_key = selected_style.get("focus_key")

    if not focus_key:
        monthly_profile["nutrition_detail_weights"] = get_nutrition_detail_weights_by_style(
            selected_style=selected_style
        )
        return monthly_profile

    weights = deepcopy(monthly_profile.get("weights", {}))

    if focus_key not in weights:
        monthly_profile["nutrition_detail_weights"] = get_nutrition_detail_weights_by_style(
            selected_style=selected_style
        )
        return monthly_profile

    weights[focus_key] += 0.2

    if focus_key == "budget":
        weights["nutrition"] = max(weights.get("nutrition", 0) - 0.05, 0)
        weights["preference"] = max(weights.get("preference", 0) - 0.03, 0)

    if focus_key == "nutrition":
        weights["budget"] = max(weights.get("budget", 0) - 0.05, 0)

    if focus_key == "difficulty":
        weights["preference"] = max(weights.get("preference", 0) - 0.03, 0)

    if focus_key == "preference":
        weights["difficulty"] = max(weights.get("difficulty", 0) - 0.03, 0)

    if "diversity" in weights:
        weights["diversity"] += 0.05

    monthly_profile["weights"] = normalize_weights(weights)

    monthly_profile["nutrition_detail_weights"] = get_nutrition_detail_weights_by_style(
        selected_style=selected_style
    )


    return monthly_profile




def build_monthly_plan(
    recommendations: list[dict],
    profile: dict,
    period_days: int,
    meal_count_per_day: int
) -> dict:
    """
    월간 식단표를 생성한다.

    selected_menu와 alternative_menus를 모두 노출 메뉴로 간주해
    대표 식단과 대안 식단의 반복을 함께 줄인다.
    """

    required_meal_count = period_days * meal_count_per_day
    available_recommendation_count = len(recommendations)

    diversity_penalty_strength = profile.get(
        "diversity_penalty_strength",
        0.2,
    )

    recent_day_window = get_recent_day_window(
        diversity_penalty_strength,
    )

    warnings = []

    if available_recommendation_count < required_meal_count:
        warnings.append(
            f"요청한 {required_meal_count}개 식단 중 조건을 통과한 추천 메뉴가 "
            f"{available_recommendation_count}개입니다. 후보가 부족한 경우 일부 메뉴가 반복 배치될 수 있습니다."
        )

    days = []
    used_menu_count = {}

    for day_number in range(1, period_days + 1):
        meals = []

        exposed_menus = get_recent_exposed_menus(
            days=days,
            recent_day_window=recent_day_window,
        )

        for meal_order in range(1, meal_count_per_day + 1):
            selected_menu = select_menu_for_meal(
                recommendations=recommendations,
                exposed_menus=exposed_menus,
                used_menu_count=used_menu_count,
                diversity_penalty_strength=diversity_penalty_strength,
                profile=profile
            )

            alternative_menus = select_alternative_menus(
                recommendations=recommendations,
                selected_menu=selected_menu,
                exposed_menus=exposed_menus,
                used_menu_count=used_menu_count,
                diversity_penalty_strength=diversity_penalty_strength,
                alternative_count=2,
            )

            increase_used_menu_count(
                used_menu_count=used_menu_count,
                menu=selected_menu,
                amount=1,
            )

            exposed_menus.append(selected_menu)

            for alternative_menu in alternative_menus:
                increase_used_menu_count(
                    used_menu_count=used_menu_count,
                    menu=alternative_menu,
                    amount=0.5,
                )

                exposed_menus.append(alternative_menu)

            meals.append({
                "meal_order": meal_order,
                "selected_menu": selected_menu,
                "alternative_menus": alternative_menus,
            })

        days.append({
            "day": day_number,
            "meals": meals,
            "total_estimated_cost": calculate_day_total_estimated_cost(meals),
            "total_calories": calculate_day_total_calories(meals),
        })

    summary = calculate_monthly_plan_summary(days)

    return {
        "period_days": period_days,
        "meal_count_per_day": meal_count_per_day,
        "required_meal_count": required_meal_count,
        "available_recommendation_count": available_recommendation_count,
        "diversity_penalty_strength": diversity_penalty_strength,
        "recent_day_window": recent_day_window,
        "warnings": warnings,
        "summary": summary,
        "days": days,
    }



def build_monthly_plan_by_random_style(
    user_id: str,
    candidate_menus: list[dict],
    profile: dict,
    meal_style_response: dict
) -> dict:
    """
    테스트용으로 3일 샘플 스타일 중 하나를 랜덤 선택한 뒤,
    해당 스타일을 기준으로 월간 식단을 생성한다.
    """

    meal_style_candidates = meal_style_response.get("meal_style_candidates", [])

    if not meal_style_candidates:
        raise ValueError("meal_style_candidates가 비어 있어 월간 식단 스타일을 선택할 수 없습니다.")

    selected_style = random.choice(meal_style_candidates)

    selected_style_summary = build_selected_style_summary(selected_style)

    period_days = profile.get("period_days", 30)
    meal_count_per_day = profile.get("meal_count_per_day", 1)

    required_candidate_count = period_days * meal_count_per_day * 3

    monthly_profile = apply_selected_style_to_profile(
        profile=profile,
        selected_style=selected_style_summary
    )

    recommendations = recommend_menus(
        menus=candidate_menus,
        profile=monthly_profile,
        top_n=len(candidate_menus)
    )

    monthly_plan = build_monthly_plan(
        recommendations=recommendations,
        profile=monthly_profile,
        period_days=period_days,
        meal_count_per_day=meal_count_per_day
    )

    summary = monthly_plan.get("summary", {})

    base_style_validation = build_style_validation(
        selected_style=selected_style_summary,
        summary=summary,
        profile=monthly_profile
    )

    style_validation = enrich_style_validation(
        style_validation=base_style_validation,
        selected_style=selected_style_summary,
        summary=summary
    )

    monthly_plan["style_validation"] = style_validation

    return build_modeling_to_back_monthly_response(
        user_id=user_id,
        selected_style=selected_style_summary,
        base_profile=profile,
        monthly_profile=monthly_profile,
        monthly_plan=monthly_plan,
        actual_recommendation_count=len(recommendations)
    )

