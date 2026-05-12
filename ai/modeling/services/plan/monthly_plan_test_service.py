import random
from datetime import datetime

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
    "다이어트"
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

    ingredients = menu.get("ingredients", [])

    return set(ingredients)


def calculate_ingredient_similarity(
    first_menu: dict,
    second_menu: dict
) -> float:
    """
    두 메뉴의 재료 유사도를 계산한다.

    Jaccard 유사도:
    공통 재료 수 / 전체 재료 수
    """

    first_ingredients = get_menu_ingredient_set(first_menu)
    second_ingredients = get_menu_ingredient_set(second_menu)

    if not first_ingredients or not second_ingredients:
        return 0

    intersection_count = len(first_ingredients & second_ingredients)
    union_count = len(first_ingredients | second_ingredients)

    if union_count == 0:
        return 0

    return intersection_count / union_count


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
    4. 재료 구성이 70% 이상 같으면 유사
    """

    first_menu_id = first_menu.get("menu_id")
    second_menu_id = second_menu.get("menu_id")

    if first_menu_id is None or second_menu_id is None:
        return False

    if first_menu_id == second_menu_id:
        return True

    first_similar_menu_ids = first_menu.get("similar_menu_ids", [])
    second_similar_menu_ids = second_menu.get("similar_menu_ids", [])

    if second_menu_id in first_similar_menu_ids:
        return True

    if first_menu_id in second_similar_menu_ids:
        return True

    first_name = normalize_menu_name(first_menu.get("name"))
    second_name = normalize_menu_name(second_menu.get("name"))

    if first_name and second_name and first_name == second_name:
        return True

    ingredient_similarity = calculate_ingredient_similarity(
        first_menu=first_menu,
        second_menu=second_menu
    )

    if ingredient_similarity >= 0.7:
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


def select_menu_for_meal(
    recommendations: list[dict],
    exposed_menus: list[dict],
    used_menu_count: dict
) -> dict:
    """
    한 끼에 들어갈 대표 메뉴를 선택한다.

    선택 기준:
    1. 최근 노출 메뉴(selected + alternative)와 유사하지 않은 메뉴 우선
    2. 사용 횟수가 적은 메뉴 우선
    3. 사용 횟수가 같으면 final_score가 높은 메뉴 우선
    """

    non_similar_candidates = []

    for menu in recommendations:
        if not is_similar_to_exposed_menus(
            menu=menu,
            exposed_menus=exposed_menus
        ):
            non_similar_candidates.append(menu)

    if non_similar_candidates:
        candidates = non_similar_candidates
    else:
        candidates = recommendations

    sorted_candidates = sorted(
        candidates,
        key=lambda menu: (
            used_menu_count.get(menu.get("menu_id"), 0),
            -menu.get("final_score", 0)
        )
    )

    return sorted_candidates[0]


def select_alternative_menus(
    recommendations: list[dict],
    selected_menu: dict,
    exposed_menus: list[dict],
    used_menu_count: dict,
    alternative_count: int = 2
) -> list[dict]:
    """
    선택 메뉴에 대한 대체 메뉴를 고른다.

    대체 메뉴는 다음 조건을 만족해야 한다.
    1. selected_menu와 같지 않아야 한다.
    2. selected_menu와 유사하지 않아야 한다.
    3. 최근 노출 메뉴와도 유사하지 않아야 한다.
    4. 대체 메뉴끼리도 서로 유사하지 않아야 한다.
    """

    alternative_menus = []

    sorted_candidates = sorted(
        recommendations,
        key=lambda menu: (
            used_menu_count.get(menu.get("menu_id"), 0),
            -menu.get("final_score", 0)
        )
    )

    for candidate_menu in sorted_candidates:
        if candidate_menu.get("menu_id") == selected_menu.get("menu_id"):
            continue

        if are_menus_similar(candidate_menu, selected_menu):
            continue

        if is_similar_to_exposed_menus(
            menu=candidate_menu,
            exposed_menus=exposed_menus
        ):
            continue

        is_similar_to_alternative = False

        for alternative_menu in alternative_menus:
            if are_menus_similar(candidate_menu, alternative_menu):
                is_similar_to_alternative = True
                break

        if is_similar_to_alternative:
            continue

        alternative_menus.append(candidate_menu)

        if len(alternative_menus) >= alternative_count:
            break

    if len(alternative_menus) >= alternative_count:
        return alternative_menus

    # 후보가 부족한 경우에도 selected_menu와 유사한 메뉴는 최대한 피한다.
    for candidate_menu in sorted_candidates:
        if candidate_menu.get("menu_id") == selected_menu.get("menu_id"):
            continue

        if are_menus_similar(candidate_menu, selected_menu):
            continue

        if candidate_menu in alternative_menus:
            continue

        alternative_menus.append(candidate_menu)

        if len(alternative_menus) >= alternative_count:
            break

    return alternative_menus


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
                used_menu_count=used_menu_count
            )

            alternative_menus = select_alternative_menus(
                recommendations=recommendations,
                selected_menu=selected_menu,
                exposed_menus=exposed_menus,
                used_menu_count=used_menu_count,
                alternative_count=2
            )

            selected_menu_id = selected_menu.get("menu_id")

            used_menu_count[selected_menu_id] = (
                used_menu_count.get(selected_menu_id, 0) + 1
            )

            exposed_menus.append(selected_menu)

            for alternative_menu in alternative_menus:
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

    return {
        "period_days": period_days,
        "meal_count_per_day": meal_count_per_day,
        "required_meal_count": required_meal_count,
        "available_recommendation_count": available_recommendation_count,
        "diversity_penalty_strength": diversity_penalty_strength,
        "recent_day_window": recent_day_window,
        "warnings": warnings,
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

    selected_style = random.choice(
        meal_style_response.get("meal_style_candidates", [])
    )

    selected_style_summary = build_selected_style_summary(selected_style)

    period_days = profile.get("period_days", 30)
    meal_count_per_day = profile.get("meal_count_per_day", 1)

    required_candidate_count = period_days * meal_count_per_day * 3

    recommendations = recommend_menus(
        menus=candidate_menus,
        profile=profile,
        top_n=len(candidate_menus)
    )

    monthly_plan = build_monthly_plan(
        recommendations=recommendations,
        profile=profile,
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
            "generated_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
        },
        "monthly_plan": monthly_plan
    }