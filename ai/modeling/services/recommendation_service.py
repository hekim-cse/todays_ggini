from services.scoring_service import (
    calculate_budget_score,
    calculate_difficulty_score,
    calculate_preference_score,
    calculate_nutrition_score,
    calculate_diversity_score
)


def has_excluded_ingredient(menu: dict, excluded_ingredients: list) -> bool:
    """
    메뉴에 사용자가 제외한 재료가 포함되어 있는지 확인한다.
    """

    menu_ingredients = menu.get("ingredients", [])

    for excluded_ingredient in excluded_ingredients:
        if excluded_ingredient in menu_ingredients:
            return True

    return False


def calculate_final_score(
    menu: dict,
    profile: dict,
    selected_menu_ids: list
) -> dict:
    """
    메뉴 하나에 대해 예산, 영양, 선호도, 난이도, 다양성 점수를 계산하고
    최종 점수를 만든다.
    """

    weights = profile["weights"]

    budget_score = calculate_budget_score(
        menu["estimated_cost"],
        profile["meal_budget"]
    )

    nutrition_score = calculate_nutrition_score(
        menu,
        profile["goals"]
    )

    preference_score = calculate_preference_score(
        menu,
        profile
    )

    difficulty_score = calculate_difficulty_score(
        menu["difficulty"],
        profile["max_difficulty"]
    )

    diversity_score = calculate_diversity_score(
        menu=menu,
        selected_menu_ids=selected_menu_ids,
        penalty_strength=profile["diversity_penalty_strength"]
    )

    final_score = (
        budget_score * weights["budget"]
        + nutrition_score * weights["nutrition"]
        + preference_score * weights["preference"]
        + difficulty_score * weights["difficulty"]
        + diversity_score * weights["diversity"]
    )

    return {
        "menu_id": menu["menu_id"],
        "name": menu["name"],
        "final_score": round(final_score, 2),
        "scores": {
            "budget": round(budget_score, 2),
            "nutrition": round(nutrition_score, 2),
            "preference": round(preference_score, 2),
            "difficulty": round(difficulty_score, 2),
            "diversity": round(diversity_score, 2)
        },
        "estimated_cost": menu["estimated_cost"],
        "calories": menu["calories"],
        "protein": menu["protein"]
    }


def recommend_menus(menus: list, profile: dict, top_n: int = 5) -> list:
    """
    메뉴를 하나씩 선택하면서 다양성 점수를 반영해 추천한다.

    기존 방식:
    모든 메뉴 점수 계산 후 정렬

    변경 방식:
    1개 메뉴를 선택할 때마다 selected_menu_ids에 추가하고,
    다음 메뉴 계산 시 이미 선택된 메뉴와의 유사성을 반영한다.
    """

    recommendations = []
    selected_menu_ids = []

    candidate_menus = []

    for menu in menus:
        if has_excluded_ingredient(
            menu=menu,
            excluded_ingredients=profile["allergy_ingredients"]
        ):
            continue

        candidate_menus.append(menu)

    while len(recommendations) < top_n and candidate_menus:
        scored_menus = []

        for menu in candidate_menus:
            result = calculate_final_score(
                menu=menu,
                profile=profile,
                selected_menu_ids=selected_menu_ids
            )

            scored_menus.append({
                "menu": menu,
                "result": result
            })

        scored_menus.sort(
            key=lambda x: x["result"]["final_score"],
            reverse=True
        )

        best_menu = scored_menus[0]["menu"]
        best_result = scored_menus[0]["result"]

        recommendations.append(best_result)
        selected_menu_ids.append(best_menu["menu_id"])

        candidate_menus = [
            menu for menu in candidate_menus
            if menu["menu_id"] != best_menu["menu_id"]
        ]

    return recommendations