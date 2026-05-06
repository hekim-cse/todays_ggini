from services.plan.diversity_service import get_recent_day_window
from services.plan.meal_candidate_service import select_menu_candidates_for_slot
from services.plan.meal_payload_service import build_menu_payload


def build_period_meal_plan(
    recommendations: list[dict],
    meal_count_per_day: int,
    period_days: int = 7,
    diversity_penalty_strength: float = 0.3
) -> dict:
    """
    추천 결과 리스트를 기반으로 기간별 식단을 구성한다.

    period_days 값에 따라 3일 샘플 식단, 7일 식단, 28일/30일 월간 식단 모두 생성할 수 있다.
    각 끼니는 selected_menu 1개와 alternative_menus 2개를 가진다.
    """

    required_meal_count = period_days * meal_count_per_day
    available_recommendation_count = len(recommendations)

    recent_day_window = get_recent_day_window(diversity_penalty_strength)

    warnings = []

    if available_recommendation_count == 0:
        warnings.append(
            "조건을 만족하는 추천 메뉴가 없습니다. 알레르기, 예산, 난이도 조건을 완화하거나 후보 메뉴 데이터를 추가해야 합니다."
        )

        return {
            "period_days": period_days,
            "meal_count_per_day": meal_count_per_day,
            "required_meal_count": required_meal_count,
            "available_recommendation_count": available_recommendation_count,
            "diversity_penalty_strength": diversity_penalty_strength,
            "recent_day_window": recent_day_window,
            "warnings": warnings,
            "days": []
        }

    if available_recommendation_count < required_meal_count:
        warnings.append(
            f"요청한 {required_meal_count}개 식단 중 조건을 통과한 추천 메뉴가 "
            f"{available_recommendation_count}개입니다. "
            "후보가 부족한 경우 일부 메뉴가 반복 배치될 수 있습니다."
        )

    period_plan = {
        "period_days": period_days,
        "meal_count_per_day": meal_count_per_day,
        "required_meal_count": required_meal_count,
        "available_recommendation_count": available_recommendation_count,
        "diversity_penalty_strength": diversity_penalty_strength,
        "recent_day_window": recent_day_window,
        "warnings": warnings,
        "days": []
    }

    recent_days_menu_ids = []

    for day in range(1, period_days + 1):
        day_plan = {
            "day": day,
            "meals": []
        }

        used_menu_ids_in_day = []

        recent_menu_ids = [
            menu_id
            for day_menu_ids in recent_days_menu_ids[-recent_day_window:]
            for menu_id in day_menu_ids
        ] if recent_day_window > 0 else []

        for meal_order in range(1, meal_count_per_day + 1):
            menu_candidates = select_menu_candidates_for_slot(
                recommendations=recommendations,
                used_menu_ids_in_day=used_menu_ids_in_day,
                recent_menu_ids=recent_menu_ids,
                diversity_penalty_strength=diversity_penalty_strength,
                candidate_count=3
            )

            if not menu_candidates:
                continue

            selected_menu = menu_candidates[0]
            alternative_menus = menu_candidates[1:3]

            meal = {
                "meal_order": meal_order,
                "selected_menu": build_menu_payload(selected_menu),
                "alternative_menus": [
                    build_menu_payload(menu)
                    for menu in alternative_menus
                ]
            }

            day_plan["meals"].append(meal)

            used_menu_ids_in_day.append(
                selected_menu["menu_id"]
            )

        day_plan["total_estimated_cost"] = sum(
            meal["selected_menu"]["estimated_cost"]
            for meal in day_plan["meals"]
        )

        day_plan["total_calories"] = sum(
            meal["selected_menu"]["calories"]
            for meal in day_plan["meals"]
        )

        period_plan["days"].append(day_plan)

        recent_days_menu_ids.append(
            used_menu_ids_in_day
        )

    return period_plan