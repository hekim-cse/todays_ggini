import random
from datetime import datetime
from copy import deepcopy
from services.recommendation.recommendation_service import recommend_menus


STYLE_PREFIX_WORDS = [
    "담백한",
    "매콤",
    "간장",
    "저칼로리",
    "고단백",
    "든든한",
    "가벼운",
    "프리미엄",
    "간편",
    "건강한",
    "저염",
    "다이어트",
    "구운",
    "라이트",
]


def get_recent_day_window(diversity_penalty_strength: float) -> int:
    """
    다양성 강도에 따라 최근 며칠의 메뉴 반복을 피할지 결정한다.
    """

    if diversity_penalty_strength <= 0.1:
        return 0

    if diversity_penalty_strength <= 0.3:
        return 1

    return 2


def get_mmr_lambda(diversity_penalty_strength: float) -> float:
    """
    MMR에서 추천 점수와 다양성 중 무엇을 더 볼지 결정한다.

    lambda 값이 높을수록 final_score를 더 중요하게 본다.
    lambda 값이 낮을수록 다양성을 더 강하게 반영한다.
    """

    if diversity_penalty_strength >= 0.6:
        return 0.55

    if diversity_penalty_strength >= 0.4:
        return 0.65

    return 0.8


def build_selected_style_summary(selected_style: dict) -> dict:
    """
    월간 식단 결과에 포함할 선택 스타일 요약 정보를 만든다.
    """

    return {
        "style_id": selected_style.get("style_id"),
        "style_name": selected_style.get("style_name"),
        "description": selected_style.get("description"),
        "summary_comment": selected_style.get("summary_comment"),
        "source_goal": selected_style.get("source_goal"),
        "focus_key": selected_style.get("focus_key")
    }


def normalize_weights(weights: dict) -> dict:
    """
    가중치 합이 1이 되도록 정규화한다.
    """

    total = sum(weights.values())

    if total == 0:
        raise ValueError("가중치 합이 0입니다.")

    return {
        key: round(value / total, 4)
        for key, value in weights.items()
    }



def get_nutrition_detail_weights_by_style(selected_style: dict) -> dict:
    """
    사용자가 선택한 스타일에 따라 nutrition 내부 세부 가중치를 만든다.

    nutrition 점수는 하나의 점수처럼 보이지만,
    내부적으로는 다음 세부 기준으로 나뉜다.

    - diet: 칼로리와 지방 중심
    - high_protein: 단백질 중심
    - balance: 탄수화물/단백질/지방 비율 중심

    예:
    - 다이어트 스타일 선택 -> diet 비중 강화
    - 고단백 스타일 선택 -> high_protein 비중 강화
    - 영양 균형 스타일 선택 -> balance 비중 강화
    """

    source_goal = selected_style.get("source_goal")

    if source_goal == "다이어트":
        return {
            "diet": 0.75,
            "high_protein": 0.10,
            "balance": 0.15
        }

    if source_goal == "고단백":
        return {
            "diet": 0.15,
            "high_protein": 0.65,
            "balance": 0.20
        }

    if source_goal == "영양 균형":
        return {
            "diet": 0.20,
            "high_protein": 0.20,
            "balance": 0.60
        }

    return {
        "diet": 0.33,
        "high_protein": 0.34,
        "balance": 0.33
    }


def apply_selected_style_to_profile(
    profile: dict,
    selected_style: dict
) -> dict:
    """
    사용자가 선택한 3일 샘플 스타일을 월간 식단 생성용 profile에 반영한다.
    """

    monthly_profile = deepcopy(profile)

    focus_key = selected_style.get("focus_key")

    if not focus_key:
        monthly_profile["nutrition_detail_weights"] = get_nutrition_detail_weights_by_style(
            selected_style=selected_style
        )
        return monthly_profile

    weights = deepcopy(monthly_profile.get("weights", {}))

    if focus_key not in weights:
        monthly_profile["nutrition_detail_weights"] = get_nutrition_detail_weights_by_style(
            selected_style=selected_style
        )
        return monthly_profile

    weights[focus_key] += 0.2

    if focus_key == "budget":
        weights["nutrition"] = max(weights.get("nutrition", 0) - 0.05, 0)
        weights["preference"] = max(weights.get("preference", 0) - 0.03, 0)

    if focus_key == "nutrition":
        weights["budget"] = max(weights.get("budget", 0) - 0.05, 0)

    if focus_key == "difficulty":
        weights["preference"] = max(weights.get("preference", 0) - 0.03, 0)

    if focus_key == "preference":
        weights["difficulty"] = max(weights.get("difficulty", 0) - 0.03, 0)

    if "diversity" in weights:
        weights["diversity"] += 0.05

    monthly_profile["weights"] = normalize_weights(weights)

    monthly_profile["nutrition_detail_weights"] = get_nutrition_detail_weights_by_style(
        selected_style=selected_style
    )

    return monthly_profile


def normalize_menu_name(name: str | None) -> str:
    """
    메뉴 이름에서 스타일 수식어를 제거해 유사 메뉴 비교용 이름을 만든다.

    예:
    - 담백한 닭가슴살 포케 -> 닭가슴살 포케
    - 저칼로리 닭가슴살 포케 -> 닭가슴살 포케
    """

    if not name:
        return ""

    normalized_name = name.strip()

    for prefix_word in STYLE_PREFIX_WORDS:
        if normalized_name.startswith(prefix_word + " "):
            normalized_name = normalized_name.replace(prefix_word + " ", "", 1)

    return normalized_name.strip()


def get_menu_ingredient_set(menu: dict) -> set:
    """
    메뉴의 재료 목록을 set 형태로 가져온다.
    """

    return set(menu.get("ingredients", []))


def get_menu_ingredient_group_set(menu: dict) -> set:
    """
    메뉴의 재료군 목록을 set 형태로 가져온다.
    """

    return set(menu.get("ingredient_groups", []))


def calculate_jaccard_similarity(first_values: set, second_values: set) -> float:
    """
    두 집합의 Jaccard 유사도를 계산한다.
    """

    if not first_values or not second_values:
        return 0

    intersection_count = len(first_values & second_values)
    union_count = len(first_values | second_values)

    if union_count == 0:
        return 0

    return intersection_count / union_count


def calculate_ingredient_similarity(
    first_menu: dict,
    second_menu: dict
) -> float:
    """
    두 메뉴의 재료 유사도를 계산한다.
    """

    return calculate_jaccard_similarity(
        get_menu_ingredient_set(first_menu),
        get_menu_ingredient_set(second_menu)
    )


def calculate_ingredient_group_similarity(
    first_menu: dict,
    second_menu: dict
) -> float:
    """
    두 메뉴의 재료군 유사도를 계산한다.
    """

    return calculate_jaccard_similarity(
        get_menu_ingredient_group_set(first_menu),
        get_menu_ingredient_group_set(second_menu)
    )


def calculate_menu_similarity_score(
    first_menu: dict,
    second_menu: dict
) -> float:
    """
    두 메뉴의 유사도를 0~1 사이 점수로 계산한다.

    menu_id, similar_menu_ids, 정규화된 이름이 같으면 거의 같은 메뉴로 본다.
    그 외에는 재료 유사도와 재료군 유사도를 함께 본다.
    """

    first_menu_id = first_menu.get("menu_id")
    second_menu_id = second_menu.get("menu_id")

    if first_menu_id is not None and second_menu_id is not None:
        if first_menu_id == second_menu_id:
            return 1

    first_similar_menu_ids = first_menu.get("similar_menu_ids", [])
    second_similar_menu_ids = second_menu.get("similar_menu_ids", [])

    if second_menu_id in first_similar_menu_ids:
        return 1

    if first_menu_id in second_similar_menu_ids:
        return 1

    first_name = normalize_menu_name(first_menu.get("name"))
    second_name = normalize_menu_name(second_menu.get("name"))

    if first_name and second_name and first_name == second_name:
        return 1

    ingredient_similarity = calculate_ingredient_similarity(
        first_menu=first_menu,
        second_menu=second_menu
    )

    ingredient_group_similarity = calculate_ingredient_group_similarity(
        first_menu=first_menu,
        second_menu=second_menu
    )

    category_similarity = 0

    if first_menu.get("category") == second_menu.get("category"):
        category_similarity = 0.2

    return max(
        ingredient_similarity,
        ingredient_group_similarity * 0.8,
        category_similarity
    )


def are_menus_similar(
    first_menu: dict,
    second_menu: dict
) -> bool:
    """
    두 메뉴가 서로 유사한지 판단한다.

    판단 기준:
    1. menu_id가 같으면 유사
    2. similar_menu_ids에 서로 포함되면 유사
    3. 수식어를 제거한 메뉴명이 같으면 유사
    4. 재료 구성이 60% 이상 같으면 유사
    5. 재료군 구성이 80% 이상 같으면 유사
    """

    similarity_score = calculate_menu_similarity_score(
        first_menu=first_menu,
        second_menu=second_menu
    )

    if similarity_score >= 0.6:
        return True

    return False


def get_recent_exposed_menus(
    days: list[dict],
    recent_day_window: int
) -> list[dict]:
    """
    최근 N일 안에 사용자에게 노출된 메뉴를 가져온다.

    여기서 노출된 메뉴는 selected_menu뿐만 아니라 alternative_menus도 포함한다.
    """

    if recent_day_window <= 0:
        return []

    recent_days = days[-recent_day_window:]
    exposed_menus = []

    for day in recent_days:
        for meal in day.get("meals", []):
            selected_menu = meal.get("selected_menu")

            if selected_menu:
                exposed_menus.append(selected_menu)

            alternative_menus = meal.get("alternative_menus", [])

            for alternative_menu in alternative_menus:
                exposed_menus.append(alternative_menu)

    return exposed_menus


def is_similar_to_exposed_menus(
    menu: dict,
    exposed_menus: list[dict]
) -> bool:
    """
    현재 후보 메뉴가 이미 노출된 메뉴와 유사한지 확인한다.
    """

    for exposed_menu in exposed_menus:
        if are_menus_similar(menu, exposed_menu):
            return True

    return False

def is_similar_to_any_menu(
    menu: dict,
    menus: list[dict]
) -> bool:
    """
    현재 후보 메뉴가 주어진 메뉴 목록 중 하나라도 유사한지 확인한다.

    대안 메뉴끼리 서로 비슷한 메뉴가 같이 들어가는 것을 막기 위해 사용한다.
    """

    for target_menu in menus:
        if are_menus_similar(menu, target_menu):
            return True

    return False


def calculate_max_similarity_to_exposed_menus(
    menu: dict,
    exposed_menus: list[dict]
) -> float:
    """
    후보 메뉴가 이미 노출된 메뉴들과 얼마나 유사한지 계산한다.
    """

    if not exposed_menus:
        return 0

    max_similarity = 0

    for exposed_menu in exposed_menus:
        similarity_score = calculate_menu_similarity_score(
            first_menu=menu,
            second_menu=exposed_menu
        )

        if similarity_score > max_similarity:
            max_similarity = similarity_score

    return max_similarity


def calculate_mmr_score(
    menu: dict,
    exposed_menus: list[dict],
    used_menu_count: dict,
    diversity_penalty_strength: float
) -> float:
    """
    MMR 방식으로 메뉴 점수를 계산한다.

    MMR = 추천 적합도 * lambda - 유사도 패널티 * (1 - lambda)

    여기에 사용 횟수 패널티를 추가해 특정 메뉴가 반복 선택되는 것을 줄인다.
    """

    lambda_score = get_mmr_lambda(diversity_penalty_strength)

    final_score = menu.get("final_score", 0)
    max_similarity = calculate_max_similarity_to_exposed_menus(
        menu=menu,
        exposed_menus=exposed_menus
    )

    menu_id = menu.get("menu_id")
    use_count = used_menu_count.get(menu_id, 0)

    relevance_score = final_score
    diversity_penalty = max_similarity * 100
    use_count_penalty = use_count * 8

    mmr_score = (
        relevance_score * lambda_score
        - diversity_penalty * (1 - lambda_score)
        - use_count_penalty
    )

    return mmr_score


def rerank_menus_by_mmr(
    recommendations: list[dict],
    exposed_menus: list[dict],
    used_menu_count: dict,
    diversity_penalty_strength: float
) -> list[dict]:
    """
    추천 후보를 MMR 점수 기준으로 재정렬한다.
    """

    reranked_menus = []

    for menu in recommendations:
        mmr_score = calculate_mmr_score(
            menu=menu,
            exposed_menus=exposed_menus,
            used_menu_count=used_menu_count,
            diversity_penalty_strength=diversity_penalty_strength
        )

        reranked_menu = {
            **menu,
            "mmr_score": round(mmr_score, 2)
        }

        reranked_menus.append(reranked_menu)

    reranked_menus.sort(
        key=lambda menu: (
            menu.get("mmr_score", 0),
            -used_menu_count.get(menu.get("menu_id"), 0),
            menu.get("final_score", 0)
        ),
        reverse=True
    )

    return reranked_menus


def select_menu_for_meal(
    recommendations: list[dict],
    exposed_menus: list[dict],
    used_menu_count: dict,
    diversity_penalty_strength: float
) -> dict:
    """
    한 끼에 들어갈 대표 메뉴를 선택한다.

    선택 기준:
    1. MMR 점수가 높은 메뉴 우선
    2. 최근 노출 메뉴(selected + alternative)와 유사하지 않은 메뉴 우선
    3. 사용 횟수가 적은 메뉴 우선
    """

    reranked_menus = rerank_menus_by_mmr(
        recommendations=recommendations,
        exposed_menus=exposed_menus,
        used_menu_count=used_menu_count,
        diversity_penalty_strength=diversity_penalty_strength
    )

    for menu in reranked_menus:
        if not is_similar_to_exposed_menus(
            menu=menu,
            exposed_menus=exposed_menus
        ):
            return menu

    return reranked_menus[0]


def select_alternative_menus(
    recommendations: list[dict],
    selected_menu: dict,
    exposed_menus: list[dict],
    used_menu_count: dict,
    diversity_penalty_strength: float,
    alternative_count: int = 2
) -> list[dict]:
    """
    선택 메뉴에 대한 대체 메뉴를 고른다.

    대안 메뉴는 사용자의 다양성 설정과 관계없이
    항상 높은 다양성 기준을 적용한다.

    이유:
    - 대안 메뉴는 사용자에게 비교 선택지를 제공하는 영역이다.
    - 대표 메뉴와 비슷한 메뉴가 대안으로 나오면 선택 의미가 약해진다.
    - 따라서 월간 식단의 다양성 설정보다 더 강하게 중복을 제한한다.
    """

    alternative_menus = []

    # 대안 메뉴는 항상 다양성을 강하게 적용한다.
    alternative_diversity_strength = max(diversity_penalty_strength, 0.8)

    # selected_menu도 이미 노출된 메뉴로 간주한다.
    local_exposed_menus = exposed_menus + [selected_menu]

    reranked_menus = rerank_menus_by_mmr(
        recommendations=recommendations,
        exposed_menus=local_exposed_menus,
        used_menu_count=used_menu_count,
        diversity_penalty_strength=alternative_diversity_strength
    )

    # 1차 선택:
    # selected_menu, 최근 노출 메뉴, 이미 고른 대안 메뉴와 모두 유사하지 않은 메뉴만 선택한다.
    for candidate_menu in reranked_menus:
        if candidate_menu.get("menu_id") == selected_menu.get("menu_id"):
            continue

        if are_menus_similar(candidate_menu, selected_menu):
            continue

        if is_similar_to_exposed_menus(
            menu=candidate_menu,
            exposed_menus=local_exposed_menus
        ):
            continue

        if is_similar_to_any_menu(
            menu=candidate_menu,
            menus=alternative_menus
        ):
            continue

        alternative_menus.append(candidate_menu)
        local_exposed_menus.append(candidate_menu)

        if len(alternative_menus) >= alternative_count:
            return alternative_menus

    # 2차 선택:
    # 후보가 부족한 경우 최근 노출 조건만 완화한다.
    # 그래도 selected_menu와 대안 메뉴끼리 유사한 것은 계속 금지한다.
    for candidate_menu in reranked_menus:
        if len(alternative_menus) >= alternative_count:
            break

        if candidate_menu.get("menu_id") == selected_menu.get("menu_id"):
            continue

        if are_menus_similar(candidate_menu, selected_menu):
            continue

        if candidate_menu in alternative_menus:
            continue

        if is_similar_to_any_menu(
            menu=candidate_menu,
            menus=alternative_menus
        ):
            continue

        alternative_menus.append(candidate_menu)
        local_exposed_menus.append(candidate_menu)

    return alternative_menus


def increase_used_menu_count(
    used_menu_count: dict,
    menu: dict,
    amount: float = 1
) -> None:
    """
    메뉴 사용 횟수를 증가시킨다.

    selected_menu는 1점,
    alternative_menus는 0.5점 정도로 반영해
    대안으로 노출된 메뉴도 다음 추천에서 너무 자주 나오지 않게 한다.
    """

    menu_id = menu.get("menu_id")

    if menu_id is None:
        return

    used_menu_count[menu_id] = used_menu_count.get(menu_id, 0) + amount


def calculate_day_total_estimated_cost(meals: list[dict]) -> int:
    """
    하루 식단의 총 예상 비용을 계산한다.
    """

    total_cost = 0

    for meal in meals:
        selected_menu = meal.get("selected_menu", {})
        total_cost += selected_menu.get("estimated_cost", 0) or 0

    return total_cost


def calculate_day_total_calories(meals: list[dict]) -> int:
    """
    하루 식단의 총 칼로리를 계산한다.
    """

    total_calories = 0

    for meal in meals:
        selected_menu = meal.get("selected_menu", {})
        total_calories += selected_menu.get("calories", 0) or 0

    return total_calories


def build_monthly_plan_summary(days: list[dict]) -> dict:
    """
    월간 식단 결과를 빠르게 검증하기 위한 요약 정보를 만든다.

    전체 monthly_plan을 다 펼쳐보지 않아도
    평균 칼로리, 평균 단백질, 총 비용, 메뉴 반복 수 등을 확인할 수 있다.
    """

    selected_menus = []
    total_estimated_cost = 0
    total_calories = 0
    total_protein = 0
    total_carbohydrate = 0
    total_fat = 0

    for day in days:
        total_estimated_cost += day.get("total_estimated_cost", 0)

        for meal in day.get("meals", []):
            selected_menu = meal.get("selected_menu", {})

            if not selected_menu:
                continue

            selected_menus.append(selected_menu)

            total_calories += selected_menu.get("calories", 0) or 0
            total_protein += selected_menu.get("protein", 0) or 0
            total_carbohydrate += selected_menu.get("carbohydrate", 0) or 0
            total_fat += selected_menu.get("fat", 0) or 0

    selected_menu_count = len(selected_menus)

    if selected_menu_count == 0:
        return {
            "selected_menu_count": 0,
            "unique_menu_count": 0,
            "duplicate_menu_count": 0,
            "total_estimated_cost": 0,
            "average_daily_cost": 0,
            "average_calories": 0,
            "average_protein": 0,
            "average_carbohydrate": 0,
            "average_fat": 0
        }

    menu_ids = [
        menu.get("menu_id")
        for menu in selected_menus
        if menu.get("menu_id") is not None
    ]

    unique_menu_count = len(set(menu_ids))
    duplicate_menu_count = len(menu_ids) - unique_menu_count
    day_count = len(days)

    average_daily_cost = 0

    if day_count > 0:
        average_daily_cost = round(total_estimated_cost / day_count)

    return {
        "selected_menu_count": selected_menu_count,
        "unique_menu_count": unique_menu_count,
        "duplicate_menu_count": duplicate_menu_count,
        "total_estimated_cost": total_estimated_cost,
        "average_daily_cost": average_daily_cost,
        "average_calories": round(total_calories / selected_menu_count, 2),
        "average_protein": round(total_protein / selected_menu_count, 2),
        "average_carbohydrate": round(total_carbohydrate / selected_menu_count, 2),
        "average_fat": round(total_fat / selected_menu_count, 2)
    }


def build_monthly_plan(
    recommendations: list[dict],
    profile: dict,
    period_days: int,
    meal_count_per_day: int
) -> dict:
    """
    월간 식단표를 생성한다.

    selected_menu와 alternative_menus를 모두 노출 메뉴로 간주해
    대표 식단과 대안 식단의 반복을 함께 줄인다.
    """

    required_meal_count = period_days * meal_count_per_day
    available_recommendation_count = len(recommendations)

    diversity_penalty_strength = profile.get(
        "diversity_penalty_strength",
        0.2
    )

    recent_day_window = get_recent_day_window(
        diversity_penalty_strength
    )

    warnings = []

    if available_recommendation_count < required_meal_count:
        warnings.append(
            f"요청한 {required_meal_count}개 식단 중 조건을 통과한 추천 메뉴가 "
            f"{available_recommendation_count}개입니다. 후보가 부족한 경우 일부 메뉴가 반복 배치될 수 있습니다."
        )

    days = []
    used_menu_count = {}

    for day_number in range(1, period_days + 1):
        meals = []

        exposed_menus = get_recent_exposed_menus(
            days=days,
            recent_day_window=recent_day_window
        )

        for meal_order in range(1, meal_count_per_day + 1):
            selected_menu = select_menu_for_meal(
                recommendations=recommendations,
                exposed_menus=exposed_menus,
                used_menu_count=used_menu_count,
                diversity_penalty_strength=diversity_penalty_strength
            )

            alternative_menus = select_alternative_menus(
                recommendations=recommendations,
                selected_menu=selected_menu,
                exposed_menus=exposed_menus,
                used_menu_count=used_menu_count,
                diversity_penalty_strength=diversity_penalty_strength,
                alternative_count=2
            )

            increase_used_menu_count(
                used_menu_count=used_menu_count,
                menu=selected_menu,
                amount=1
            )

            exposed_menus.append(selected_menu)

            for alternative_menu in alternative_menus:
                increase_used_menu_count(
                    used_menu_count=used_menu_count,
                    menu=alternative_menu,
                    amount=0.5
                )

                exposed_menus.append(alternative_menu)

            meals.append({
                "meal_order": meal_order,
                "selected_menu": selected_menu,
                "alternative_menus": alternative_menus
            })

        days.append({
            "day": day_number,
            "meals": meals,
            "total_estimated_cost": calculate_day_total_estimated_cost(meals),
            "total_calories": calculate_day_total_calories(meals)
        })

    summary = build_monthly_plan_summary(days)

    return {
        "period_days": period_days,
        "meal_count_per_day": meal_count_per_day,
        "required_meal_count": required_meal_count,
        "available_recommendation_count": available_recommendation_count,
        "diversity_penalty_strength": diversity_penalty_strength,
        "recent_day_window": recent_day_window,
        "warnings": warnings,
        "summary": summary,
        "days": days
    }


def build_monthly_plan_by_random_style(
    user_id: str,
    candidate_menus: list[dict],
    profile: dict,
    meal_style_response: dict
) -> dict:
    """
    테스트용으로 3일 샘플 스타일 중 하나를 랜덤 선택한 뒤,
    해당 스타일을 기준으로 월간 식단을 생성한다.
    """

    meal_style_candidates = meal_style_response.get("meal_style_candidates", [])

    if not meal_style_candidates:
        raise ValueError("meal_style_candidates가 비어 있어 월간 식단 스타일을 선택할 수 없습니다.")

    selected_style = random.choice(meal_style_candidates)

    selected_style_summary = build_selected_style_summary(selected_style)

    period_days = profile.get("period_days", 30)
    meal_count_per_day = profile.get("meal_count_per_day", 1)

    required_candidate_count = period_days * meal_count_per_day * 3

    monthly_profile = apply_selected_style_to_profile(
        profile=profile,
        selected_style=selected_style_summary
    )

    recommendations = recommend_menus(
        menus=candidate_menus,
        profile=monthly_profile,
        top_n=len(candidate_menus)
    )

    monthly_plan = build_monthly_plan(
        recommendations=recommendations,
        profile=monthly_profile,
        period_days=period_days,
        meal_count_per_day=meal_count_per_day
    )

    return {
        "user_id": user_id,
        "request_type": "monthly_meal_plan_test",
        "selected_style": selected_style_summary,
        "meta": {
            "period_days": period_days,
            "meal_count_per_day": meal_count_per_day,
            "required_candidate_count": required_candidate_count,
            "actual_recommendation_count": len(recommendations),
            "base_weights": profile.get("weights"),
            "applied_style_focus_key": selected_style_summary.get("focus_key"),
            "applied_monthly_weights": monthly_profile.get("weights"),
            "applied_nutrition_detail_weights": monthly_profile.get("nutrition_detail_weights"),
            "generated_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
        "monthly_plan": monthly_plan
    }