def calculate_budget_score(menu_cost: int, meal_budget: int) -> float:
    """
    메뉴 가격이 한 끼 예산 안에 들어오면 100점이다.
    예산을 초과하면 초과 비율만큼 점수를 깎는다.
    """

    if menu_cost <= meal_budget:
        return 100

    score = 100 - ((menu_cost - meal_budget) / meal_budget) * 100

    return max(0, score)


def calculate_difficulty_score(menu_difficulty: int, cooking_skill: int) -> float:
    """
    메뉴 난이도가 사용자 요리 실력보다 낮거나 같으면 100점이다.
    사용자 실력보다 어려우면 단계 차이마다 30점씩 감점한다.
    """

    if menu_difficulty <= cooking_skill:
        return 100

    score = 100 - (menu_difficulty - cooking_skill) * 30

    return max(0, score)


def calculate_category_score(menu_category: str, preferred_categories: list) -> float:
    """
    메뉴 카테고리가 사용자의 선호 카테고리에 포함되면 100점이다.
    상관없음을 선택한 경우 카테고리 영향은 중립 점수로 처리한다.
    """

    if "상관없음" in preferred_categories:
        return 70

    if menu_category in preferred_categories:
        return 100

    return 40


def calculate_ingredient_score(menu_ingredient_groups: list, ingredient_preferences: dict) -> float:
    """
    메뉴에 포함된 재료군이 사용자의 선호도와 얼마나 맞는지 계산한다.

    ingredient_preferences 예:
    {
        "육류": 4,
        "해산물류": 2,
        "식물성 단백질류": 5
    }

    선호도는 1~5점이므로 100점 기준으로 변환한다.
    """

    if not menu_ingredient_groups:
        return 50

    scores = []

    for group in menu_ingredient_groups:
        preference_value = ingredient_preferences.get(group, 3)

        # 1~5 값을 20~100점으로 변환한다.
        converted_score = preference_value * 20
        scores.append(converted_score)

    return sum(scores) / len(scores)


def calculate_preference_score(menu: dict, profile: dict) -> float:
    """
    사용자 선호 카테고리와 선호 재료군을 바탕으로 선호도 점수를 계산한다.

    선호도 점수 = 카테고리 점수 50% + 재료군 점수 50%

    카테고리 점수:
    - 메뉴 카테고리가 사용자의 preferred_categories에 포함되면 100점
    - 아니면 50점

    재료군 점수:
    - 사용자가 선택한 ingredient_preferences와
      메뉴의 ingredient_groups가 얼마나 겹치는지 비율로 계산
    """

    preferred_categories = profile.get("preferred_categories", [])
    preferred_ingredient_groups = profile.get("ingredient_preferences", [])

    menu_category = menu.get("category")
    menu_ingredient_groups = menu.get("ingredient_groups", [])

    # 1. 카테고리 점수
    if menu_category in preferred_categories:
        category_score = 100
    else:
        category_score = 50

    # 2. 재료군 선호도 점수
    if not preferred_ingredient_groups:
        ingredient_score = 50
    else:
        matched_count = 0

        for ingredient_group in menu_ingredient_groups:
            if ingredient_group in preferred_ingredient_groups:
                matched_count += 1

        ingredient_score = (
            matched_count / len(preferred_ingredient_groups)
        ) * 100

        # 점수가 100을 넘지 않도록 제한
        ingredient_score = min(ingredient_score, 100)

    preference_score = category_score * 0.5 + ingredient_score * 0.5

    return preference_score

def calculate_nutrition_score(menu: dict, goals: list) -> float:
    """
    사용자의 목적에 따라 영양 점수를 계산한다.
    MVP 단계에서는 단순 기준으로 시작한다.
    """

    calories = menu["calories"]
    protein = menu["protein"]

    if goals == "다이어트":
        # 칼로리가 낮을수록 높은 점수
        if calories <= 500:
            return 100
        elif calories <= 700:
            return 80
        elif calories <= 900:
            return 60
        else:
            return 40

    if goals == "고단백":
        # 단백질이 높을수록 높은 점수
        if protein >= 30:
            return 100
        elif protein >= 20:
            return 80
        elif protein >= 10:
            return 60
        else:
            return 40

    if goals == "영양 균형":
        # 너무 낮거나 너무 높은 칼로리를 피한다.
        if 500 <= calories <= 800 and protein >= 15:
            return 100
        elif 400 <= calories <= 900:
            return 80
        else:
            return 60

    # 식비 절약, 간편식, 맛 중심은 기본 영양 점수 부여
    return 70

def calculate_diversity_score(
    menu: dict,
    selected_menu_ids: list,
    penalty_strength: float
) -> float:
    """
    이미 선택된 메뉴들과 현재 메뉴가 비슷한지 확인하고 다양성 점수를 계산한다.

    menu:
    현재 점수를 계산할 메뉴이다.

    selected_menu_ids:
    이미 추천 식단에 포함된 메뉴 ID 목록이다.

    penalty_strength:
    사용자의 다양성 선호도에 따른 감점 강도이다.
    낮음: 0.1
    보통: 0.3
    높음: 0.5

    현재 메뉴가 이미 선택된 메뉴와 비슷하면 감점한다.
    """

    similar_menu_ids = menu.get("similar_menu_ids", [])

    for selected_menu_id in selected_menu_ids:
        if selected_menu_id in similar_menu_ids:
            diversity_score = 100 - (100 * penalty_strength)
            return max(0, diversity_score)

    return 100