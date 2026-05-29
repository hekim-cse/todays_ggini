def build_optimizer_input(
    recommendations: list[dict],
    profile: dict,
    period_days: int,
    meal_count_per_day: int,
) -> dict:
    """
    OR-Tools optimizer에서 사용할 입력 데이터를 만든다.

    recommendations:
    - 기존 scoring + re-ranking이 끝난 후보 메뉴 목록이다.
    - OR-Tools는 이 후보를 바탕으로 월간 식단 슬롯에 메뉴를 배치한다.

    profile:
    - 사용자 예산, 영양 목표, 선호 조건 등이 들어 있는 모델링 profile이다.

    period_days:
    - 생성할 식단 기간이다.

    meal_count_per_day:
    - 하루 식사 개수이다.
    """

    slots = []

    for day in range(1, period_days + 1):
        for meal_order in range(1, meal_count_per_day + 1):
            slots.append({
                "day": day,
                "meal_order": meal_order,
            })

    menus = []

    for index, menu in enumerate(recommendations):
        menus.append({
            "index": index,
            "menu_id": menu.get("menu_id"),
            "name": menu.get("name"),
            "estimated_cost": int(menu.get("estimated_cost", 0) or 0),
            "calories": float(menu.get("calories", 0) or 0),
            "protein": float(menu.get("protein", 0) or 0),
            "final_score": float(menu.get("final_score", 0) or 0),
            "preference_score": float(
                menu.get("scores", {}).get("preference_score", 0)
                if isinstance(menu.get("scores"), dict)
                else 0
            ),
            "raw_menu": menu,
        })

    return {
        "profile": profile,
        "period_days": period_days,
        "meal_count_per_day": meal_count_per_day,
        "slots": slots,
        "menus": menus,
        "max_repeat_per_menu": profile.get("max_repeat_per_menu", 2),
        "solver_time_limit_seconds": profile.get("solver_time_limit_seconds", 10),
        "score_weight": profile.get("score_weight", 100),
        "cost_penalty_weight": profile.get("cost_penalty_weight", 1),
        "cost_penalty_divisor": profile.get("cost_penalty_divisor", 100),
        "repeat_penalty_weight": profile.get("repeat_penalty_weight", 300),
    }
