def calculate_budget_score(menu_cost: int | None, meal_budget: int) -> float:
    """
    메뉴 가격이 한 끼 예산 안에 들어오면 100점이다.
    예산을 초과하면 초과 비율만큼 점수를 깎는다.

    menu_cost가 없으면 가격 판단이 불가능하므로 중립 점수 70점을 부여한다.
    """

    if menu_cost is None or menu_cost <= 0:
        return 70

    if meal_budget <= 0:
        return 70

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


def calculate_category_score(
    menu_category: str,
    preferred_categories: list[str]
) -> float:
    """
    메뉴 카테고리가 사용자의 선호 카테고리에 포함되는지 계산한다.

    상관없음을 선택한 경우 카테고리 영향은 중립 점수로 처리한다.
    """

    if "상관없음" in preferred_categories:
        return 70

    if menu_category in preferred_categories:
        return 100

    return 40


def calculate_ingredient_score(
    menu_ingredient_groups: list[str],
    ingredient_preferences: list[str]
) -> float:
    """
    메뉴의 재료군이 사용자가 선택한 선호 재료군과 얼마나 겹치는지 계산한다.

    ingredient_preferences 예:
    ["육류", "식물성 단백질류"]

    계산 방식:
    겹친 재료군 수 / 사용자가 선택한 선호 재료군 수 * 100
    """

    if not ingredient_preferences:
        return 50

    if not menu_ingredient_groups:
        return 50

    matched_count = 0

    for ingredient_group in menu_ingredient_groups:
        if ingredient_group in ingredient_preferences:
            matched_count += 1

    score = (matched_count / len(ingredient_preferences)) * 100

    return min(score, 100)


def calculate_preference_score(menu: dict, profile: dict) -> float:
    """
    사용자 선호 카테고리와 선호 재료군을 바탕으로 선호도 점수를 계산한다.

    선호도 점수 = 카테고리 점수 50% + 재료군 점수 50%
    """

    preferred_categories = profile.get("preferred_categories", [])
    ingredient_preferences = profile.get("ingredient_preferences", [])

    menu_category = menu.get("category", "")
    menu_ingredient_groups = menu.get("ingredient_groups", [])

    category_score = calculate_category_score(
        menu_category=menu_category,
        preferred_categories=preferred_categories
    )

    ingredient_score = calculate_ingredient_score(
        menu_ingredient_groups=menu_ingredient_groups,
        ingredient_preferences=ingredient_preferences
    )

    preference_score = category_score * 0.5 + ingredient_score * 0.5

    return preference_score


def get_menu_nutrients(menu: dict) -> dict:
    """
    메뉴 영양 정보를 통일된 형태로 가져온다.

    기존 sample_menus 구조와
    RAG nutrient_summary 구조를 모두 지원한다.

    지원 구조 1:
    {
        "calories": 580,
        "protein": 24,
        "carbohydrate": 72,
        "fat": 14
    }

    지원 구조 2:
    {
        "calories": 580,
        "nutrient_summary": {
            "carbohydrate": 72,
            "protein": 24,
            "fat": 14
        }
    }
    """

    nutrient_summary = menu.get("nutrient_summary", {})

    return {
        "calories": menu.get("calories", 0),
        "carbohydrate": menu.get(
            "carbohydrate",
            nutrient_summary.get("carbohydrate", 0)
        ),
        "protein": menu.get(
            "protein",
            nutrient_summary.get("protein", 0)
        ),
        "fat": menu.get(
            "fat",
            nutrient_summary.get("fat", 0)
        )
    }


def calculate_diet_nutrition_score(nutrients: dict) -> float:
    """
    다이어트 목표의 영양 점수를 계산한다.

    다이어트는 칼로리와 지방을 중심으로 본다.
    칼로리가 낮고 지방이 과하지 않으면 높은 점수를 준다.
    """

    calories = nutrients["calories"]
    fat = nutrients["fat"]

    if calories <= 500 and fat <= 15:
        return 100

    if calories <= 650 and fat <= 20:
        return 85

    if calories <= 800 and fat <= 25:
        return 70

    if calories <= 950:
        return 55

    return 40


def calculate_high_protein_nutrition_score(nutrients: dict) -> float:
    """
    고단백 목표의 영양 점수를 계산한다.

    고단백은 단백질 함량을 가장 중요하게 본다.
    """

    protein = nutrients["protein"]

    if protein >= 35:
        return 100

    if protein >= 30:
        return 95

    if protein >= 25:
        return 90

    if protein >= 20:
        return 80

    if protein >= 15:
        return 65

    if protein >= 10:
        return 50

    return 35


def calculate_nutrition_balance_score(nutrients: dict) -> float:
    """
    영양 균형 목표의 영양 점수를 계산한다.

    영양 균형은 단순히 단백질만 보는 것이 아니라,
    칼로리와 탄수화물/단백질/지방 비율을 함께 본다.

    현재는 g 단위 기준의 비율을 사용한다.
    추후 더 정교하게 하려면 kcal 환산 비율을 사용할 수 있다.
    """

    calories = nutrients["calories"]
    carbohydrate = nutrients["carbohydrate"]
    protein = nutrients["protein"]
    fat = nutrients["fat"]

    total_macro = carbohydrate + protein + fat

    if total_macro <= 0:
        return 60

    carbohydrate_ratio = carbohydrate / total_macro
    protein_ratio = protein / total_macro
    fat_ratio = fat / total_macro

    # 가장 이상적인 균형 범위
    if (
        0.45 <= carbohydrate_ratio <= 0.65
        and 0.15 <= protein_ratio <= 0.35
        and 0.15 <= fat_ratio <= 0.35
        and 400 <= calories <= 850
    ):
        return 100

    # 어느 정도 허용 가능한 균형 범위
    if (
        0.35 <= carbohydrate_ratio <= 0.70
        and 0.10 <= protein_ratio <= 0.40
        and 0.10 <= fat_ratio <= 0.45
        and 350 <= calories <= 950
    ):
        return 80

    return 60


def calculate_nutrition_score(menu: dict, goals: list[str]) -> float:
    """
    사용자의 목적에 따라 영양 점수를 계산한다.

    고단백, 다이어트, 영양 균형은 모두 nutrition이라는 큰 항목에 포함되지만,
    내부 계산 기준은 서로 다르다.

    - 다이어트: 칼로리와 지방 중심
    - 고단백: 단백질 중심
    - 영양 균형: 칼로리와 탄단지 비율 중심

    여러 목표가 선택된 경우 각 목표별 영양 점수를 계산한 뒤 평균을 낸다.

    예:
    goals = ["고단백", "영양 균형"]

    high_protein_score = 단백질 기준 점수
    balance_score = 탄단지 균형 기준 점수

    nutrition_score = (high_protein_score + balance_score) / 2
    """

    nutrients = get_menu_nutrients(menu)
    nutrition_scores = []

    if "다이어트" in goals:
        diet_score = calculate_diet_nutrition_score(nutrients)
        nutrition_scores.append(diet_score)

    if "고단백" in goals:
        high_protein_score = calculate_high_protein_nutrition_score(nutrients)
        nutrition_scores.append(high_protein_score)

    if "영양 균형" in goals:
        balance_score = calculate_nutrition_balance_score(nutrients)
        nutrition_scores.append(balance_score)

    # 식비 절약, 간편식, 맛 중심만 선택된 경우 기본 영양 점수
    if not nutrition_scores:
        return 70

    return round(sum(nutrition_scores) / len(nutrition_scores), 2)


def calculate_diversity_score(
    menu: dict,
    selected_menu_ids: list,
    penalty_strength: float
) -> float:
    """
    이미 선택된 메뉴들과 현재 메뉴가 비슷한지 확인하고 다양성 점수를 계산한다.

    현재 메뉴가 이미 선택된 메뉴와 비슷하면 사용자 다양성 선호도에 따라 감점한다.
    """

    similar_menu_ids = menu.get("similar_menu_ids", [])

    for selected_menu_id in selected_menu_ids:
        if selected_menu_id in similar_menu_ids:
            diversity_score = 100 - (100 * penalty_strength)
            return max(0, diversity_score)

    return 100