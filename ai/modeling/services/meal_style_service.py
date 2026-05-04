from copy import deepcopy
from datetime import datetime, timezone

from services.recommendation_service import recommend_menus
from services.weekly_plan_service import build_weekly_meal_plan


GOAL_STYLE_META = {
    "식비 절약": {
        "style_id": "budget_first",
        "style_name": "가성비 최우선",
        "description": "예산을 가장 우선으로 고려한 식단",
        "summary_comment": "예산 부담을 줄이고 간편하게 구성한 식단입니다.",
        "focus_key": "budget"
    },
    "영양 균형": {
        "style_id": "nutrition_balance",
        "style_name": "영양 균형식",
        "description": "칼로리와 단백질 균형을 함께 고려한 식단",
        "summary_comment": "영양 균형을 고려해 건강하게 구성한 식단입니다.",
        "focus_key": "nutrition"
    },
    "다이어트": {
        "style_id": "diet_light",
        "style_name": "가벼운 관리식",
        "description": "칼로리 부담을 줄이고 가볍게 구성한 식단",
        "summary_comment": "부담이 적은 메뉴를 중심으로 구성한 식단입니다.",
        "focus_key": "nutrition"
    },
    "고단백": {
        "style_id": "high_protein",
        "style_name": "고단백 관리식",
        "description": "단백질 섭취를 우선으로 고려한 식단",
        "summary_comment": "단백질 섭취를 늘리고 싶은 사용자에게 적합한 식단입니다.",
        "focus_key": "nutrition"
    },
    "간편식": {
        "style_id": "easy_cooking",
        "style_name": "간편 조리식",
        "description": "조리 난이도와 시간을 낮게 유지한 식단",
        "summary_comment": "조리 부담을 줄이고 빠르게 준비할 수 있는 식단입니다.",
        "focus_key": "difficulty"
    },
    "맛 중심": {
        "style_id": "taste_first",
        "style_name": "취향 맞춤식",
        "description": "선호 카테고리와 재료 취향을 더 많이 반영한 식단",
        "summary_comment": "사용자의 취향과 선호 재료를 중심으로 구성한 식단입니다.",
        "focus_key": "preference"
    }
}


DISPLAY_LABELS = {
    "health": "건강",
    "cost_efficiency": "가성비",
    "taste": "맛",
    "cooking_ease": "조리"
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


def boost_style_weights(
    base_weights: dict,
    focus_key: str,
    boost_amount: float = 0.1
) -> dict:
    """
    사용자의 전체 목표 가중치를 유지하되,
    특정 스타일의 핵심 항목만 살짝 강화한다.
    """

    style_weights = deepcopy(base_weights)

    if focus_key not in style_weights:
        raise ValueError(f"지원하지 않는 focus_key입니다: {focus_key}")

    style_weights[focus_key] += boost_amount

    return normalize_weights(style_weights)


def build_profile_with_style_weights(
    profile: dict,
    style_weights: dict
) -> dict:
    """
    기존 profile은 유지하고, weights만 스타일 가중치로 교체한다.
    """

    style_profile = deepcopy(profile)
    style_profile["weights"] = style_weights

    return style_profile


def get_candidate_style_metas(profile: dict) -> list[dict]:
    """
    사용자가 선택한 goals를 기반으로 스타일 후보 3개를 만든다.

    사용자가 선택한 목표가 3개면 해당 목표 3개를 사용한다.
    사용자가 선택한 목표가 1~2개면, 나머지는 기본 스타일로 채운다.
    """

    selected_goals = profile["goals"]
    style_metas = []

    for goal in selected_goals:
        if goal in GOAL_STYLE_META:
            style_metas.append({
                **GOAL_STYLE_META[goal],
                "source_goal": goal,
                "is_support_style": False
            })

    if len(style_metas) < 3:
        for goal, meta in GOAL_STYLE_META.items():
            if goal in selected_goals:
                continue

            style_metas.append({
                **meta,
                "source_goal": goal,
                "is_support_style": True
            })

            if len(style_metas) == 3:
                break

    return style_metas[:3]


def score_to_display_scale(score: float) -> int:
    """
    0~100 점수를 사용자 표시용 1~10 점수로 변환한다.
    """

    converted_score = round(score / 10)

    if converted_score < 1:
        return 1

    if converted_score > 10:
        return 10

    return converted_score


def calculate_average_scores(recommendations: list[dict]) -> dict:
    """
    추천 메뉴들의 내부 scores 평균을 계산한다.
    """

    if not recommendations:
        return {
            "budget": 0,
            "nutrition": 0,
            "preference": 0,
            "difficulty": 0,
            "diversity": 0
        }

    score_sums = {
        "budget": 0,
        "nutrition": 0,
        "preference": 0,
        "difficulty": 0,
        "diversity": 0
    }

    for recommendation in recommendations:
        scores = recommendation.get("scores", {})

        for key in score_sums:
            score_sums[key] += scores.get(key, 0)

    count = len(recommendations)

    return {
        key: score_sums[key] / count
        for key in score_sums
    }


def build_display_scores(recommendations: list[dict]) -> dict:
    """
    스타일 카드에 보여줄 건강/가성비/맛/조리 점수를 만든다.

    내부 점수 매핑:
    nutrition  -> health
    budget     -> cost_efficiency
    preference -> taste
    difficulty -> cooking_ease
    """

    average_scores = calculate_average_scores(recommendations)

    return {
        "health": score_to_display_scale(average_scores["nutrition"]),
        "cost_efficiency": score_to_display_scale(average_scores["budget"]),
        "taste": score_to_display_scale(average_scores["preference"]),
        "cooking_ease": score_to_display_scale(average_scores["difficulty"])
    }


def simplify_meal_for_sample(meal: dict) -> dict:
    """
    3일치 샘플 카드에 필요한 메뉴 정보만 남긴다.

    샘플 후보 화면에서는 레시피 전체나 내부 점수까지 보여줄 필요가 없으므로
    가벼운 구조로 변환한다.
    """

    return {
        "meal_order": meal["meal_order"],
        "menu_id": meal["menu_id"],
        "name": meal["name"],
        "category": meal.get("category"),
        "estimated_cost": meal.get("estimated_cost"),
        "calories": meal.get("calories"),
        "protein": meal.get("protein")
    }


def simplify_sample_plan(sample_plan: dict) -> dict:
    """
    build_weekly_meal_plan() 결과를 샘플 카드용 구조로 가볍게 변환한다.
    """

    simplified_days = []

    for day in sample_plan.get("days", []):
        simplified_meals = [
            simplify_meal_for_sample(meal)
            for meal in day.get("meals", [])
        ]

        simplified_days.append({
            "day": day["day"],
            "meals": simplified_meals
        })

    return {
        "period_days": sample_plan["period_days"],
        "meal_count_per_day": sample_plan["meal_count_per_day"],
        "days": simplified_days
    }


def get_generated_at() -> str:
    """
    UTC 기준 생성 시각을 ISO 형식 문자열로 반환한다.
    """

    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def build_meal_style_candidates(
    user_id: str,
    candidate_menus: list[dict],
    profile: dict,
    meal_count_per_day: int,
    sample_period_days: int = 3
) -> dict:
    """
    사용자 목표 기반으로 식단 스타일 후보 3개를 생성한다.

    반환 구조:
    {
      "user_id": "...",
      "request_type": "meal_style_candidates",
      "meta": {...},
      "meal_style_candidates": [...]
    }
    """

    style_metas = get_candidate_style_metas(profile)
    meal_style_candidates = []

    warnings = []

    for style_meta in style_metas:
        focus_key = style_meta["focus_key"]

        style_weights = boost_style_weights(
            base_weights=profile["weights"],
            focus_key=focus_key,
            boost_amount=0.1
        )

        style_profile = build_profile_with_style_weights(
            profile=profile,
            style_weights=style_weights
        )

        required_sample_meal_count = sample_period_days * meal_count_per_day

        recommendations = recommend_menus(
            menus=candidate_menus,
            profile=style_profile,
            top_n=required_sample_meal_count
        )

        sample_plan = build_weekly_meal_plan(
            recommendations=recommendations,
            meal_count_per_day=meal_count_per_day,
            period_days=sample_period_days,
            diversity_penalty_strength=profile["diversity_penalty_strength"]
        )

        warnings.extend(sample_plan.get("warnings", []))

        meal_style_candidates.append({
            "style_id": style_meta["style_id"],
            "style_name": style_meta["style_name"],
            "description": style_meta["description"],
            "summary_comment": style_meta["summary_comment"],
            "source_goal": style_meta.get("source_goal"),
            "focus_key": focus_key,
            "display_scores": build_display_scores(recommendations),
            "display_labels": DISPLAY_LABELS,
            "sample_plan": simplify_sample_plan(sample_plan)
        })

    return {
        "user_id": user_id,
        "request_type": "meal_style_candidates",
        "meta": {
            "sample_period_days": sample_period_days,
            "meal_count_per_day": meal_count_per_day,
            "total_style_count": len(meal_style_candidates),
            "generated_at": get_generated_at(),
            "warnings": warnings
        },
        "meal_style_candidates": meal_style_candidates
    }