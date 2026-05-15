import random
from datetime import datetime
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



def calculate_day_total_estimated_cost(meals: list[dict]) -> int:
    """
    하루 식단의 총 예상 비용을 계산한다.
    """

    total_cost = 0

    for meal in meals:
        selected_menu = meal.get("selected_menu", {})
        total_cost += selected_menu.get("estimated_cost", 0) or 0

    return total_cost


def calculate_day_total_calories(meals: list[dict]) -> int:
    """
    하루 식단의 총 칼로리를 계산한다.
    """

    total_calories = 0

    for meal in meals:
        selected_menu = meal.get("selected_menu", {})
        total_calories += selected_menu.get("calories", 0) or 0

    return total_calories


def calculate_monthly_plan_summary(days: list[dict]) -> dict:
    """
    월간 식단 결과를 요약한다.

    전체 monthly_plan을 다 펼쳐보지 않아도
    평균 칼로리, 평균 단백질, 총 비용, 메뉴 반복 수, 평균 점수를 확인할 수 있다.
    """

    selected_menus = []

    for day in days:
        for meal in day.get("meals", []):
            selected_menu = meal.get("selected_menu")

            if selected_menu:
                selected_menus.append(selected_menu)

    selected_menu_count = len(selected_menus)

    if selected_menu_count == 0:
        return {
            "selected_menu_count": 0,
            "unique_menu_count": 0,
            "duplicate_menu_count": 0,
            "total_estimated_cost": 0,
            "average_daily_cost": 0,
            "average_calories": 0,
            "average_protein": 0,
            "average_carbohydrate": 0,
            "average_fat": 0,
            "average_nutrition_score": 0,
            "average_budget_score": 0,
            "average_preference_score": 0,
            "average_difficulty_score": 0,
            "average_diversity_score": 0,
        }

    menu_ids = [
        menu.get("menu_id")
        for menu in selected_menus
        if menu.get("menu_id") is not None
    ]

    unique_menu_count = len(set(menu_ids))
    duplicate_menu_count = selected_menu_count - unique_menu_count

    total_estimated_cost = sum(
        menu.get("estimated_cost", 0) or 0
        for menu in selected_menus
    )

    total_calories = sum(
        menu.get("calories", 0) or 0
        for menu in selected_menus
    )

    total_protein = sum(
        menu.get("protein", 0) or 0
        for menu in selected_menus
    )

    total_carbohydrate = sum(
        menu.get("carbohydrate", 0) or 0
        for menu in selected_menus
    )

    total_fat = sum(
        menu.get("fat", 0) or 0
        for menu in selected_menus
    )

    total_nutrition_score = sum(
        menu.get("scores", {}).get("nutrition", 0) or 0
        for menu in selected_menus
    )

    total_budget_score = sum(
        menu.get("scores", {}).get("budget", 0) or 0
        for menu in selected_menus
    )

    total_preference_score = sum(
        menu.get("scores", {}).get("preference", 0) or 0
        for menu in selected_menus
    )

    total_difficulty_score = sum(
        menu.get("scores", {}).get("difficulty", 0) or 0
        for menu in selected_menus
    )

    total_diversity_score = sum(
        menu.get("scores", {}).get("diversity", 0) or 0
        for menu in selected_menus
    )

    day_count = len(days)

    average_daily_cost = 0

    if day_count > 0:
        average_daily_cost = round(total_estimated_cost / day_count)

    return {
        "selected_menu_count": selected_menu_count,
        "unique_menu_count": unique_menu_count,
        "duplicate_menu_count": duplicate_menu_count,
        "total_estimated_cost": total_estimated_cost,
        "average_daily_cost": average_daily_cost,
        "average_calories": round(total_calories / selected_menu_count, 2),
        "average_protein": round(total_protein / selected_menu_count, 2),
        "average_carbohydrate": round(total_carbohydrate / selected_menu_count, 2),
        "average_fat": round(total_fat / selected_menu_count, 2),
        "average_nutrition_score": round(total_nutrition_score / selected_menu_count, 2),
        "average_budget_score": round(total_budget_score / selected_menu_count, 2),
        "average_preference_score": round(total_preference_score / selected_menu_count, 2),
        "average_difficulty_score": round(total_difficulty_score / selected_menu_count, 2),
        "average_diversity_score": round(total_diversity_score / selected_menu_count, 2),
    }


def build_style_validation(
    selected_style: dict,
    summary: dict,
    profile: dict
) -> dict:
    """
    선택한 스타일이 월간 식단 결과에 잘 반영되었는지 검증한다.
    """

    source_goal = selected_style.get("source_goal")
    focus_key = selected_style.get("focus_key")
    style_name = selected_style.get("style_name")

    if source_goal == "고단백":
        return validate_high_protein_style(
            style_name=style_name,
            summary=summary,
        )

    if source_goal == "다이어트":
        return validate_diet_style(
            style_name=style_name,
            summary=summary,
        )

    if source_goal == "영양 균형":
        return validate_balance_style(
            style_name=style_name,
            summary=summary,
        )

    if source_goal == "식비 절약":
        return validate_budget_style(
            style_name=style_name,
            summary=summary,
            profile=profile,
        )

    if source_goal == "간편식":
        return validate_easy_cooking_style(
            style_name=style_name,
            summary=summary,
        )

    if source_goal == "맛 중심":
        return validate_preference_style(
            style_name=style_name,
            summary=summary,
            focus_key=focus_key,
        )

    return {
        "target_style": source_goal,
        "status": "unknown",
        "message": "지원하지 않는 스타일이므로 검증 기준을 적용하지 못했습니다.",
        "checked_metrics": {},
    }


def validate_high_protein_style(
    style_name: str,
    summary: dict
) -> dict:
    """
    고단백 스타일 검증.

    월간 식단은 여러 메뉴를 섞어 구성되므로,
    모든 끼니가 30g 이상 단백질을 가지기는 어렵다.
    따라서 평균 28g 이상이면 고단백 스타일이 충분히 반영된 것으로 본다.
    """

    average_protein = summary.get("average_protein", 0)

    if average_protein >= 28:
        status = "pass"
        message = "고단백 스타일에 맞게 평균 단백질이 충분히 높게 구성되었습니다."
    elif average_protein >= 25:
        status = "warning"
        message = "고단백 스타일이 어느 정도 반영되었지만, 평균 단백질을 조금 더 높일 여지가 있습니다."
    else:
        status = "fail"
        message = "고단백 스타일에 비해 평균 단백질이 낮아 보완이 필요합니다."

    return {
        "target_style": style_name,
        "status": status,
        "message": message,
        "checked_metrics": {
            "average_protein": average_protein,
            "recommended_minimum_protein": 28,
        },
    }


def validate_diet_style(
    style_name: str,
    summary: dict
) -> dict:
    """
    다이어트 스타일 검증.
    """

    average_calories = summary.get("average_calories", 0)
    average_fat = summary.get("average_fat", 0)

    if average_calories <= 650 and average_fat <= 23:
        status = "pass"
        message = "다이어트 스타일에 맞게 평균 칼로리와 지방이 낮게 구성되었습니다."
    elif average_calories <= 750 and average_fat <= 28:
        status = "warning"
        message = "다이어트 스타일이 어느 정도 반영되었지만, 일부 메뉴의 칼로리나 지방을 더 낮출 수 있습니다."
    else:
        status = "fail"
        message = "다이어트 스타일에 비해 평균 칼로리 또는 지방이 높아 보완이 필요합니다."

    return {
        "target_style": style_name,
        "status": status,
        "message": message,
        "checked_metrics": {
            "average_calories": average_calories,
            "average_fat": average_fat,
            "recommended_max_calories": 650,
            "recommended_max_fat": 23,
        },
    }


def validate_balance_style(
    style_name: str,
    summary: dict
) -> dict:
    """
    영양 균형 스타일 검증.
    """

    average_carbohydrate = summary.get("average_carbohydrate", 0)
    average_protein = summary.get("average_protein", 0)
    average_fat = summary.get("average_fat", 0)

    total_macro = average_carbohydrate + average_protein + average_fat

    if total_macro <= 0:
        return {
            "target_style": style_name,
            "status": "unknown",
            "message": "탄수화물, 단백질, 지방 정보가 부족해 영양 균형을 검증할 수 없습니다.",
            "checked_metrics": {},
        }

    carbohydrate_ratio = average_carbohydrate / total_macro
    protein_ratio = average_protein / total_macro
    fat_ratio = average_fat / total_macro

    is_strict_balance = (
        0.45 <= carbohydrate_ratio <= 0.65
        and 0.15 <= protein_ratio <= 0.35
        and 0.15 <= fat_ratio <= 0.35
    )

    is_loose_balance = (
        0.35 <= carbohydrate_ratio <= 0.70
        and 0.10 <= protein_ratio <= 0.40
        and 0.10 <= fat_ratio <= 0.45
    )

    if is_strict_balance:
        status = "pass"
        message = "탄수화물, 단백질, 지방 비율이 안정적이어서 영양 균형 스타일이 잘 반영되었습니다."
    elif is_loose_balance:
        status = "warning"
        message = "영양 균형이 대체로 무난하지만, 일부 영양 비율은 조정할 여지가 있습니다."
    else:
        status = "fail"
        message = "영양 균형 스타일에 비해 탄수화물, 단백질, 지방 비율 조정이 필요합니다."

    return {
        "target_style": style_name,
        "status": status,
        "message": message,
        "checked_metrics": {
            "carbohydrate_ratio": round(carbohydrate_ratio, 4),
            "protein_ratio": round(protein_ratio, 4),
            "fat_ratio": round(fat_ratio, 4),
            "average_carbohydrate": average_carbohydrate,
            "average_protein": average_protein,
            "average_fat": average_fat,
        },
    }


def validate_budget_style(
    style_name: str,
    summary: dict,
    profile: dict
) -> dict:
    """
    가성비 스타일 검증.
    """

    total_estimated_cost = summary.get("total_estimated_cost", 0)
    average_daily_cost = summary.get("average_daily_cost", 0)

    monthly_budget = profile.get("monthly_budget", 0)
    period_days = profile.get("period_days", 30)
    meal_count_per_day = profile.get("meal_count_per_day", 1)
    meal_budget = profile.get("meal_budget", 0)

    if monthly_budget <= 0:
        monthly_budget = meal_budget * period_days * meal_count_per_day

    if monthly_budget <= 0:
        return {
            "target_style": style_name,
            "status": "unknown",
            "message": "예산 정보가 부족해 가성비 스타일을 검증할 수 없습니다.",
            "checked_metrics": {},
        }

    budget_usage_rate = total_estimated_cost / monthly_budget

    if budget_usage_rate <= 0.85:
        status = "pass"
        message = "월 예산 안에서 여유 있게 식단이 구성되어 가성비 스타일이 잘 반영되었습니다."
    elif budget_usage_rate <= 1.0:
        status = "warning"
        message = "월 예산 안에는 들어오지만, 예산 여유가 크지는 않습니다."
    else:
        status = "fail"
        message = "월 예산을 초과하여 가성비 스타일 보완이 필요합니다."

    return {
        "target_style": style_name,
        "status": status,
        "message": message,
        "checked_metrics": {
            "total_estimated_cost": total_estimated_cost,
            "monthly_budget": monthly_budget,
            "budget_usage_rate": round(budget_usage_rate, 4),
            "average_daily_cost": average_daily_cost,
        },
    }


def validate_easy_cooking_style(
    style_name: str,
    summary: dict
) -> dict:
    """
    간편식 스타일 검증.

    현재 난이도는 재료 수, 조리 단계 수, 조리 시간, 조리 동작 키워드를 기반으로 계산된다.
    월간 식단 전체 평균 기준에서는 75점 이상이면 간편식 스타일이 잘 반영된 것으로 본다.
    """

    average_difficulty_score = summary.get("average_difficulty_score", 0)

    if average_difficulty_score >= 75:
        status = "pass"
        message = "조리 난이도 점수가 충분히 높아 간편식 스타일이 잘 반영되었습니다."
    elif average_difficulty_score >= 65:
        status = "warning"
        message = "간편식 스타일이 어느 정도 반영되었지만, 더 쉬운 메뉴를 늘릴 수 있습니다."
    else:
        status = "fail"
        message = "간편식 스타일에 비해 조리 난이도 부담이 있어 보완이 필요합니다."

    return {
        "target_style": style_name,
        "status": status,
        "message": message,
        "checked_metrics": {
            "average_difficulty_score": average_difficulty_score,
            "recommended_minimum_difficulty_score": 75,
        },
    }


def validate_preference_style(
    style_name: str,
    summary: dict,
    focus_key: str
) -> dict:
    """
    취향 맞춤 스타일 검증.
    """

    average_preference_score = summary.get("average_preference_score", 0)

    if average_preference_score >= 85:
        status = "pass"
        message = "선호도 점수가 높아 취향 맞춤식 스타일이 잘 반영되었습니다."
    elif average_preference_score >= 70:
        status = "warning"
        message = "취향 맞춤식이 어느 정도 반영되었지만, 선호 카테고리나 재료 반영을 더 강화할 수 있습니다."
    else:
        status = "fail"
        message = "취향 맞춤식에 비해 선호도 점수가 낮아 보완이 필요합니다."

    return {
        "target_style": style_name,
        "status": status,
        "message": message,
        "checked_metrics": {
            "average_preference_score": average_preference_score,
            "applied_focus_key": focus_key,
            "recommended_minimum_preference_score": 85,
        },
    }


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


def build_secondary_warnings(summary: dict) -> list[dict]:
    """
    월간 식단 결과의 보조 경고 목록을 만든다.

    style_validation은 선택한 스타일이 잘 반영되었는지 보는 1차 검증이고,
    secondary_warnings는 그 외에 사용자 경험상 아쉬울 수 있는 부분을 알려준다.
    """

    warnings = []

    average_difficulty_score = summary.get("average_difficulty_score", 0)
    average_preference_score = summary.get("average_preference_score", 0)
    average_diversity_score = summary.get("average_diversity_score", 0)
    duplicate_menu_count = summary.get("duplicate_menu_count", 0)

    if average_difficulty_score < 60:
        warnings.append({
            "type": "difficulty",
            "level": "warning",
            "message": "평균 조리 난이도 점수가 낮아 사용자에게 조리 부담이 있을 수 있습니다.",
            "value": average_difficulty_score,
            "recommended_minimum": 60
        })

    if average_preference_score < 60:
        warnings.append({
            "type": "preference",
            "level": "warning",
            "message": "선호도 점수가 낮아 사용자 취향 반영이 약할 수 있습니다.",
            "value": average_preference_score,
            "recommended_minimum": 60
        })

    if average_diversity_score < 75:
        warnings.append({
            "type": "diversity",
            "level": "warning",
            "message": "다양성 점수가 낮아 유사 메뉴 반복 가능성이 있습니다.",
            "value": average_diversity_score,
            "recommended_minimum": 75
        })

    if duplicate_menu_count > 0:
        warnings.append({
            "type": "duplicate_menu",
            "level": "info",
            "message": "월간 식단 내 동일 menu_id가 일부 반복되었습니다.",
            "value": duplicate_menu_count
        })

    return warnings


def build_recommendation_hint(
    selected_style: dict,
    validation_status: str
) -> str:
    """
    스타일 검증 결과에 따른 다음 개선 방향 힌트를 만든다.
    """

    source_goal = selected_style.get("source_goal")

    if validation_status == "pass":
        return "현재 선택한 스타일이 월간 식단에 안정적으로 반영되었습니다."

    if source_goal == "고단백":
        return "고단백 스타일에서는 단백질 25g 이상 메뉴를 우선 배치하거나, protein 기준 soft constraint를 강화할 수 있습니다."

    if source_goal == "다이어트":
        return "다이어트 스타일에서는 지방 25g 이상 메뉴의 감점을 강화하고, 평균 칼로리 기준을 더 엄격하게 적용할 수 있습니다."

    if source_goal == "영양 균형":
        return "영양 균형 스타일에서는 탄수화물, 단백질, 지방 비율이 안정적인 메뉴를 더 우선하도록 balance 점수 가중치를 조정할 수 있습니다."

    if source_goal == "식비 절약":
        return "가성비 스타일에서는 월 예산 사용률과 한 끼 예산 초과율을 기준으로 예산 soft constraint를 강화할 수 있습니다."

    if source_goal == "간편식":
        return "간편식 스타일에서는 조리 시간, 재료 수, 조리 단계 수를 함께 반영해 난이도 점수를 더 세분화할 수 있습니다."

    if source_goal == "맛 중심":
        return "취향 맞춤식에서는 선호 카테고리와 선호 재료군 일치도를 더 강하게 반영할 수 있습니다."

    return "선택한 스타일의 검증 기준을 추가로 정의할 수 있습니다."


def enrich_style_validation(
    style_validation: dict,
    selected_style: dict,
    summary: dict
) -> dict:
    """
    기본 style_validation 결과에 보조 경고와 개선 힌트를 추가한다.

    스타일 자체 기준은 통과해도,
    동일 메뉴 반복이 많으면 사용자 경험상 완전한 pass로 보기 어렵다.
    """

    secondary_warnings = build_secondary_warnings(summary)

    duplicate_menu_count = summary.get("duplicate_menu_count", 0)
    selected_menu_count = summary.get("selected_menu_count", 0)

    validation_status = style_validation.get("status", "unknown")

    if selected_menu_count > 0:
        duplicate_rate = duplicate_menu_count / selected_menu_count
    else:
        duplicate_rate = 0

    adjusted_style_validation = dict(style_validation)

    if validation_status == "pass" and duplicate_rate >= 0.25:
        adjusted_style_validation["status"] = "warning"
        adjusted_style_validation["message"] = (
            adjusted_style_validation.get("message", "")
            + " 다만 동일 메뉴 반복 비율이 높아 월간 식단 다양성 보완이 필요합니다."
        )

    recommendation_hint = build_recommendation_hint(
        selected_style=selected_style,
        validation_status=adjusted_style_validation.get("status", "unknown")
    )

    return {
        **adjusted_style_validation,
        "secondary_warnings": secondary_warnings,
        "recommendation_hint": recommendation_hint
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


def build_modeling_profile_summary(profile: dict) -> dict:
    """
    Back에서 저장하거나 추적하기 좋은 모델링 프로필 요약 정보를 만든다.

    사용자 입력값과 모델링 계산값을 함께 포함한다.
    """

    return {
        "goals": profile.get("goals", []),
        "monthly_budget": profile.get("monthly_budget"),
        "period_days": profile.get("period_days"),
        "meal_count_per_day": profile.get("meal_count_per_day"),
        "cooking_skill": profile.get("cooking_skill"),
        "preferred_categories": profile.get("preferred_categories", []),
        "diversity_level": profile.get("diversity_level"),
        "ingredient_preferences": profile.get("ingredient_preferences", []),
        "allergy_ingredients": profile.get("allergy_ingredients", []),

        "budget_period_days": profile.get("budget_period_days"),
        "sample_period_days": profile.get("sample_period_days"),
        "meal_budget": profile.get("meal_budget"),
        "weights": profile.get("weights", {}),
        "max_difficulty": profile.get("max_difficulty"),
        "diversity_penalty_strength": profile.get("diversity_penalty_strength"),
    }


def build_applied_style_adjustment(
    base_profile: dict,
    monthly_profile: dict,
    selected_style: dict
) -> dict:
    """
    선택한 스타일이 월간 식단 가중치에 어떻게 반영되었는지 정리한다.
    """

    return {
        "applied_style_focus_key": selected_style.get("focus_key"),
        "base_weights": base_profile.get("weights", {}),
        "applied_monthly_weights": monthly_profile.get("weights", {}),
        "applied_nutrition_detail_weights": monthly_profile.get(
            "nutrition_detail_weights",
            {}
        ),
    }


def filter_reasons_by_focus_key(
    reasons: list[dict],
    focus_key: str | None
) -> list[dict]:
    """
    선택한 스타일의 focus_key에 맞는 추천 이유만 남긴다.

    예:
    - focus_key == "budget"이면 budget reason만 반환
    - focus_key == "nutrition"이면 nutrition reason만 반환
    """

    if not focus_key:
        return reasons

    filtered_reasons = [
        reason for reason in reasons
        if reason.get("type") == focus_key
    ]

    if filtered_reasons:
        return filtered_reasons

    return reasons[:1]


def format_menu_for_back(
    menu: dict,
    focus_key: str | None
) -> dict:
    """
    selected_menu / alternative_menu 응답 필드 순서를 Back 전달용으로 정리한다.
    """

    nutrient_summary = menu.get("nutrient_summary", {})

    return {
        "menu_id": menu.get("menu_id"),
        "name": menu.get("name"),
        "category": menu.get("category"),

        "final_score": menu.get("final_score"),
        "base_final_score": menu.get("base_final_score"),
        "style_soft_constraint_score": menu.get("style_soft_constraint_score"),
        "mmr_score": menu.get("mmr_score"),

        "estimated_cost": menu.get("estimated_cost"),
        "rag_estimated_cost": menu.get("rag_estimated_cost"),
        "pricing_status": menu.get("pricing_status"),

        "calories": menu.get("calories", 0),
        "protein": menu.get("protein", nutrient_summary.get("protein", 0)),
        "carbohydrate": menu.get(
            "carbohydrate",
            nutrient_summary.get("carbohydrate", 0)
        ),
        "fat": menu.get("fat", nutrient_summary.get("fat", 0)),
        "nutrient_summary": nutrient_summary,

        "ingredients": menu.get("ingredients", []),
        "ingredient_groups": menu.get("ingredient_groups", []),
        "ingredient_usages": menu.get("ingredient_usages", []),
        "ingredient_costs": menu.get("ingredient_costs", []),

        "difficulty": menu.get("difficulty"),
        "difficulty_detail": menu.get("difficulty_detail", {}),

        "recipe": menu.get("recipe", {}),

        "scores": menu.get("scores", {}),
        "reasons": filter_reasons_by_focus_key(
            reasons=menu.get("reasons", []),
            focus_key=focus_key
        ),

        "similar_menu_ids": menu.get("similar_menu_ids", []),
        "allergy_ingredients": menu.get("allergy_ingredients", []),
    }


def format_monthly_plan_for_back(
    monthly_plan: dict,
    focus_key: str | None
) -> dict:
    """
    월간 식단 내부 구조를 Back 전달용으로 정리한다.

    - summary 유지
    - style_validation 위치 보장
    - days 내부 selected_menu / alternative_menus 필드 순서 통일
    """

    formatted_days = []

    for day in monthly_plan.get("days", []):
        formatted_meals = []

        for meal in day.get("meals", []):
            selected_menu = meal.get("selected_menu", {})
            alternative_menus = meal.get("alternative_menus", [])

            formatted_meals.append({
                "meal_order": meal.get("meal_order"),
                "selected_menu": format_menu_for_back(
                    menu=selected_menu,
                    focus_key=focus_key
                ),
                "alternative_menus": [
                    format_menu_for_back(
                        menu=alternative_menu,
                        focus_key=focus_key
                    )
                    for alternative_menu in alternative_menus
                ],
            })

        formatted_days.append({
            "day": day.get("day"),
            "meals": formatted_meals,
            "total_estimated_cost": day.get("total_estimated_cost", 0),
            "total_calories": day.get("total_calories", 0),
        })

    return {
        "period_days": monthly_plan.get("period_days"),
        "meal_count_per_day": monthly_plan.get("meal_count_per_day"),
        "required_meal_count": monthly_plan.get("required_meal_count"),
        "available_recommendation_count": monthly_plan.get(
            "available_recommendation_count"
        ),
        "diversity_penalty_strength": monthly_plan.get(
            "diversity_penalty_strength"
        ),
        "recent_day_window": monthly_plan.get("recent_day_window"),
        "warnings": monthly_plan.get("warnings", []),
        "summary": monthly_plan.get("summary", {}),
        "style_validation": monthly_plan.get("style_validation", {}),
        "days": formatted_days,
    }


def build_modeling_to_back_monthly_response(
    user_id: str,
    selected_style: dict,
    base_profile: dict,
    monthly_profile: dict,
    monthly_plan: dict,
    actual_recommendation_count: int
) -> dict:
    """
    Modeling → Back 월간 식단 추천 최종 응답 JSON을 만든다.

    이 함수에서 응답 구조를 고정하면,
    내부 추천 로직이 바뀌어도 Back/Front와 맞춘 응답 형식을 유지할 수 있다.
    """

    focus_key = selected_style.get("focus_key")

    period_days = monthly_plan.get("period_days")
    meal_count_per_day = monthly_plan.get("meal_count_per_day")
    required_meal_count = monthly_plan.get("required_meal_count")

    return {
        "user_id": user_id,
        "request_type": "monthly_plan",
        "selected_style": selected_style,
        "meta": {
            "period_days": period_days,
            "meal_count_per_day": meal_count_per_day,
            "required_meal_count": required_meal_count,
            "available_recommendation_count": actual_recommendation_count,
            "generated_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
            "warnings": monthly_plan.get("warnings", []),
        },
        "modeling_profile": build_modeling_profile_summary(
            profile=base_profile
        ),
        "applied_style_adjustment": build_applied_style_adjustment(
            base_profile=base_profile,
            monthly_profile=monthly_profile,
            selected_style=selected_style
        ),
        "monthly_plan": format_monthly_plan_for_back(
            monthly_plan=monthly_plan,
            focus_key=focus_key
        ),
    }