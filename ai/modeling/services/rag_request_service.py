def build_rag_request(
    user_input,
    profile: dict,
    candidate_count: int
) -> dict:
    """
    Modeling 파트에서 RAG 파트로 넘길 요청 JSON을 생성한다.

    RAG는 user_conditions.allergy_ingredients를 기준으로
    알레르기 재료가 포함된 메뉴를 1차 제외한다.

    Modeling은 RAG 응답 이후 ingredients 기준으로
    한 번 더 안전 필터링을 수행한다.
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
    period_days: int = 7
) -> int:
    """
    필요한 후보 메뉴 개수를 계산한다.

    예:
    하루 2끼 × 7일 = 14개
    하루 3끼 × 7일 = 21개
    """

    return meal_count_per_day * period_days