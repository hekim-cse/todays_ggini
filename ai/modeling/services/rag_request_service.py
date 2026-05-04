def build_rag_request(
    user_input,
    profile: dict,
    candidate_count: int
) -> dict:
    """
    Modeling 파트에서 RAG 파트로 넘길 요청 JSON을 생성한다.

    ingredient_preferences는 재료군별 점수가 아니라,
    사용자가 중복 선택한 선호 재료군 목록이다.
    """

    return {
        "request_type": "weekly_meal_candidates",
        "candidate_count": candidate_count,
        "user_conditions": {
            "goals": profile["goals"],
            "meal_budget": profile["meal_budget"],
            "preferred_categories": profile["preferred_categories"],
            "max_difficulty": profile["max_difficulty"],
            "ingredient_preferences": profile["ingredient_preferences"],
            "allergy_ingredients": profile["allergy_ingredients"],
        },
        "required_fields": [
            "menu_id",
            "name",
            "category",
            "ingredients",
            "ingredient_groups",
            "difficulty",
            "estimated_cost",
            "calories",
            "protein",
            "recipe",
        ],
        "optional_fields": [
            "similar_menu_ids",
            "allergy_ingredients",
        ],
    }


def calculate_candidate_count(
    meal_count_per_day: int,
    period_days: int = 7,
    buffer_multiplier: int = 3
) -> int:
    """
    RAG에 요청할 후보 메뉴 개수를 계산한다.

    실제 식단에 필요한 메뉴 수보다 여유 있게 요청한다.

    예:
    하루 2끼 × 7일 × 3배수 = 42개 후보 요청
    """

    return meal_count_per_day * period_days * buffer_multiplier