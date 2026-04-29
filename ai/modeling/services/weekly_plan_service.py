def build_weekly_meal_plan(
    recommendations: list[dict],
    meal_count_per_day: int,
    period_days: int = 7
) -> dict:
    """
    추천 결과 리스트를 기반으로 7일치 식단을 구성한다.

    recommendations:
    - recommend_menus()가 반환한 추천 메뉴 리스트

    meal_count_per_day:
    - 하루 식사 수

    period_days:
    - 기본 7일
    """

    if not recommendations:
        return {
            "period_days": period_days,
            "meal_count_per_day": meal_count_per_day,
            "days": []
        }

    weekly_plan = {
        "period_days": period_days,
        "meal_count_per_day": meal_count_per_day,
        "days": []
    }

    recommendation_index = 0

    for day in range(1, period_days + 1):
        day_plan = {
            "day": day,
            "meals": []
        }

        for meal_order in range(1, meal_count_per_day + 1):
            menu = recommendations[recommendation_index % len(recommendations)]

            meal = {
                "meal_order": meal_order,
                "menu_id": menu["menu_id"],
                "name": menu["name"],
                "final_score": menu["final_score"],
                "estimated_cost": menu["estimated_cost"],
                "calories": menu["calories"],
                "protein": menu["protein"],
                "scores": menu["scores"]
            }

            day_plan["meals"].append(meal)
            recommendation_index += 1

        weekly_plan["days"].append(day_plan)

    return weekly_plan