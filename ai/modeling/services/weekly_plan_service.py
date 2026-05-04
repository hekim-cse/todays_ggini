def get_recent_day_window(diversity_penalty_strength: float) -> int:
    """
    메뉴 다양성 감점 강도에 따라 최근 며칠 동안 먹은 메뉴를 피할지 결정한다.

    낮음: 0.1 → 반복 허용, 최근 메뉴 거의 신경 쓰지 않음
    보통: 0.3 → 최근 1일 메뉴는 가능하면 피함
    높음: 0.5 → 최근 2일 메뉴는 가능하면 피함
    """

    if diversity_penalty_strength <= 0.1:
        return 0

    if diversity_penalty_strength <= 0.3:
        return 1

    return 2


def is_similar_menu(menu: dict, selected_menu_ids: list[int]) -> bool:
    """
    현재 메뉴가 이미 선택된 메뉴들과 유사한지 확인한다.

    similar_menu_ids에 selected_menu_ids 중 하나라도 포함되어 있으면
    유사 메뉴로 판단한다.
    """

    similar_menu_ids = menu.get("similar_menu_ids", [])

    for selected_menu_id in selected_menu_ids:
        if selected_menu_id in similar_menu_ids:
            return True

    return False


def select_best_menu_for_slot(
    recommendations: list[dict],
    used_menu_ids_in_day: list[int],
    recent_menu_ids: list[int],
    diversity_penalty_strength: float,
    allow_repeat: bool = False
) -> dict:
    """
    한 끼 자리에 들어갈 메뉴를 선택한다.

    다양성 선택값에 따라 반복 허용 정도를 다르게 적용한다.

    낮음:
    - 같은 메뉴 반복을 비교적 허용한다.
    - 같은 날 동일 메뉴만 피한다.

    보통:
    - 같은 날 동일 메뉴를 피한다.
    - 최근 1일 메뉴를 가능하면 피한다.

    높음:
    - 같은 날 동일 메뉴를 피한다.
    - 같은 날 유사 메뉴를 피한다.
    - 최근 2일 메뉴를 가능하면 피한다.
    """

    candidates = []

    for menu in recommendations:
        menu_id = menu["menu_id"]

        # 같은 날 동일 메뉴는 모든 다양성 단계에서 피한다.
        if menu_id in used_menu_ids_in_day and not allow_repeat:
            continue

        # 다양성이 높은 경우에만 같은 날 유사 메뉴를 강하게 피한다.
        if diversity_penalty_strength >= 0.5:
            if is_similar_menu(menu, used_menu_ids_in_day) and not allow_repeat:
                continue

        # 다양성이 보통 이상이면 최근 메뉴 반복을 피한다.
        if diversity_penalty_strength >= 0.3:
            if menu_id in recent_menu_ids and not allow_repeat:
                continue

        candidates.append(menu)

    if candidates:
        candidates.sort(
            key=lambda menu: menu["final_score"],
            reverse=True
        )
        return candidates[0]

    # 조건을 만족하는 후보가 없으면 반복 허용
    if not allow_repeat:
        return select_best_menu_for_slot(
            recommendations=recommendations,
            used_menu_ids_in_day=used_menu_ids_in_day,
            recent_menu_ids=recent_menu_ids,
            diversity_penalty_strength=diversity_penalty_strength,
            allow_repeat=True
        )

    return recommendations[0]


def build_weekly_meal_plan(
    recommendations: list[dict],
    meal_count_per_day: int,
    period_days: int = 7,
    diversity_penalty_strength: float = 0.3
) -> dict:
    """
    추천 결과 리스트를 기반으로 7일치 식단을 구성한다.

    후보 메뉴가 부족한 경우 warnings에 안내 메시지를 추가한다.
    메뉴 다양성 선택값에 따라 반복 허용 정도를 조절한다.
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

        if diversity_penalty_strength <= 0.1:

            warnings.append(

                f"요청한 {required_meal_count}개 식단 중 조건을 통과한 추천 메뉴가 "

                f"{available_recommendation_count}개입니다. "

                "사용자가 메뉴 다양성을 낮게 설정했으므로 일부 메뉴 반복을 허용하여 식단을 구성합니다."

            )

        elif diversity_penalty_strength <= 0.3:

            warnings.append(

                f"요청한 {required_meal_count}개 식단 중 조건을 통과한 추천 메뉴가 "

                f"{available_recommendation_count}개입니다. "

                "사용자가 메뉴 다양성을 보통으로 설정했으므로 최근 식단과의 반복을 일부 줄이되, "

                "후보가 부족한 경우 일부 메뉴가 반복 배치될 수 있습니다."

            )

        else:

            warnings.append(

                f"요청한 {required_meal_count}개 식단 중 조건을 통과한 추천 메뉴가 "

                f"{available_recommendation_count}개입니다. "

                "사용자가 메뉴 다양성을 높게 설정했으므로 최근 식단 및 유사 메뉴 반복을 최대한 피하지만, "

                "후보가 부족한 경우 일부 메뉴가 반복 배치될 수 있습니다."

            )

    weekly_plan = {
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

        # 다양성 설정에 따라 최근 며칠의 메뉴를 피할지 결정
        recent_menu_ids = [
            menu_id
            for day_menu_ids in recent_days_menu_ids[-recent_day_window:]
            for menu_id in day_menu_ids
        ] if recent_day_window > 0 else []

        for meal_order in range(1, meal_count_per_day + 1):
            menu = select_best_menu_for_slot(
                recommendations=recommendations,
                used_menu_ids_in_day=used_menu_ids_in_day,
                recent_menu_ids=recent_menu_ids,
                diversity_penalty_strength=diversity_penalty_strength
            )

            meal = {
                "meal_order": meal_order,
                "menu_id": menu["menu_id"],
                "name": menu["name"],
                "category": menu.get("category"),
                "final_score": menu["final_score"],
                "estimated_cost": menu["estimated_cost"],
                "calories": menu["calories"],
                "protein": menu["protein"],
                "ingredients": menu.get("ingredients", []),
                "ingredient_groups": menu.get("ingredient_groups", []),
                "recipe": menu.get("recipe", {}),
                "scores": menu["scores"]
            }

            day_plan["meals"].append(meal)
            used_menu_ids_in_day.append(menu["menu_id"])

        weekly_plan["days"].append(day_plan)
        recent_days_menu_ids.append(used_menu_ids_in_day)

    return weekly_plan