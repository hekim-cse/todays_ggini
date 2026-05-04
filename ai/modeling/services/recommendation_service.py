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

    RAG에서 알레르기 재료가 포함된 메뉴를 1차 제외하더라도,
    모델링 파트에서 ingredients 기준으로 한 번 더 안전 필터링한다.
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

    RAG에서 받은 recipe, ingredients 등의 상세 정보도
    최종 추천 결과에 함께 포함한다.
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
        "category": menu.get("category"),
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
        "protein": menu["protein"],

        # RAG에서 받은 메뉴 상세 정보
        "ingredients": menu.get("ingredients", []),
        "ingredient_groups": menu.get("ingredient_groups", []),
        "similar_menu_ids": menu.get("similar_menu_ids", []),

        # RAG에서 받은 레시피 정보
        # 아직 mock 데이터에 recipe가 없으면 빈 dict로 들어간다.
        "recipe": menu.get("recipe", {})
    }


def recommend_menus(menus: list, profile: dict, top_n: int = 5) -> list:
    """
    메뉴를 하나씩 선택하면서 다양성 점수를 반영해 추천한다.

    흐름:
    1. 알레르기/제외 재료가 포함된 메뉴를 먼저 제거한다.
    2. 남은 후보 메뉴를 대상으로 점수를 계산한다.
    3. 가장 점수가 높은 메뉴를 하나 선택한다.
    4. 선택된 메뉴 ID를 selected_menu_ids에 추가한다.
    5. 다음 메뉴 계산 시 유사 메뉴 감점을 반영한다.
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