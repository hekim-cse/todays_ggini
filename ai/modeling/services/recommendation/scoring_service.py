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


def calculate_nutrition_score(menu: dict, goals: list[str]) -> float:
    """
    사용자의 목적에 따라 영양 점수를 계산한다.

    RAG의 nutrient_summary 구조를 지원한다.
    """

    nutrients = get_menu_nutrients(menu)

    calories = nutrients["calories"]
    carbohydrate = nutrients["carbohydrate"]
    protein = nutrients["protein"]
    fat = nutrients["fat"]

    nutrition_scores = []

    if "다이어트" in goals:
        if calories <= 500 and fat <= 15:
            nutrition_scores.append(100)
        elif calories <= 650 and fat <= 20:
            nutrition_scores.append(85)
        elif calories <= 800:
            nutrition_scores.append(70)
        elif calories <= 950:
            nutrition_scores.append(55)
        else:
            nutrition_scores.append(40)

    if "고단백" in goals:
        if protein >= 30:
            nutrition_scores.append(100)
        elif protein >= 25:
            nutrition_scores.append(90)
        elif protein >= 20:
            nutrition_scores.append(80)
        elif protein >= 15:
            nutrition_scores.append(65)
        elif protein >= 10:
            nutrition_scores.append(50)
        else:
            nutrition_scores.append(35)

    if "영양 균형" in goals:
        total_macro = carbohydrate + protein + fat

        if total_macro <= 0:
            nutrition_scores.append(60)
        else:
            carbohydrate_ratio = carbohydrate / total_macro
            protein_ratio = protein / total_macro
            fat_ratio = fat / total_macro

            if (
                0.45 <= carbohydrate_ratio <= 0.65
                and 0.15 <= protein_ratio <= 0.35
                and 0.15 <= fat_ratio <= 0.35
                and 400 <= calories <= 850
            ):
                nutrition_scores.append(100)
            elif (
                0.35 <= carbohydrate_ratio <= 0.70
                and 0.10 <= protein_ratio <= 0.40
                and 0.10 <= fat_ratio <= 0.45
                and 350 <= calories <= 950
            ):
                nutrition_scores.append(80)
            else:
                nutrition_scores.append(60)

    # 식비 절약, 간편식, 맛 중심만 선택된 경우 기본 영양 점수
    if not nutrition_scores:
        return 70

    return sum(nutrition_scores) / len(nutrition_scores)


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

def get_menu_nutrients(menu: dict) -> dict:
    """
    메뉴 영양 정보를 통일된 형태로 가져온다.

    기존 sample_menus 구조와
    RAG nutrient_summary 구조를 모두 지원한다.
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