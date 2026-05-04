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

    후보 메뉴가 부족한 경우 warnings에 안내 메시지를 추가한다.
    """

    required_meal_count = period_days * meal_count_per_day
    available_recommendation_count = len(recommendations)

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
            "warnings": warnings,
            "days": []
        }

    if available_recommendation_count < required_meal_count:
        warnings.append(
            f"요청한 {required_meal_count}개 식단 후보 중 조건을 통과한 추천 메뉴가 {available_recommendation_count}개입니다. 부족한 메뉴는 반복 배치됩니다."
        )

    weekly_plan = {
        "period_days": period_days,
        "meal_count_per_day": meal_count_per_day,
        "required_meal_count": required_meal_count,
        "available_recommendation_count": available_recommendation_count,
        "warnings": warnings,
        "days": []
    }

    recommendation_index = 0

    for day in range(1, period_days + 1):
        day_plan = {
            "day": day,
            "meals": []
        }

        for meal_order in range(1, meal_count_per_day + 1):
            menu = recommendations[recommendation_index % available_recommendation_count]

            meal = {
                "meal_order": meal_order,
                "menu_id": menu["menu_id"],
                "name": menu["name"],
                "category": menu.get("category"),
                "final_score": menu["final_score"],
                "estimated_cost": menu["estimated_cost"],
                "calories": menu["calories"],
                "protein": menu["protein"],

                # 프론트에서 메뉴 상세 표시용으로 사용 가능
                "ingredients": menu.get("ingredients", []),
                "ingredient_groups": menu.get("ingredient_groups", []),

                # RAG에서 받은 레시피 정보
                "recipe": menu.get("recipe", {}),

                # 점수 근거 확인용
                "scores": menu["scores"]
            }

            day_plan["meals"].append(meal)
            recommendation_index += 1

        weekly_plan["days"].append(day_plan)

    return weekly_plan