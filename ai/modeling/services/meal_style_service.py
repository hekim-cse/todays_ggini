from copy import deepcopy

from services.recommendation_service import recommend_menus
from services.weekly_plan_service import build_weekly_meal_plan


GOAL_STYLE_META = {
    "식비 절약": {
        "style_id": "budget_first",
        "style_name": "가성비 최우선",
        "description": "예산을 가장 우선으로 고려한 식단",
        "focus_key": "budget"
    },
    "영양 균형": {
        "style_id": "nutrition_balance",
        "style_name": "영양 균형식",
        "description": "칼로리와 단백질 균형을 함께 고려한 식단",
        "focus_key": "nutrition"
    },
    "다이어트": {
        "style_id": "diet_light",
        "style_name": "가벼운 관리식",
        "description": "칼로리 부담을 줄이고 가볍게 구성한 식단",
        "focus_key": "nutrition"
    },
    "고단백": {
        "style_id": "high_protein",
        "style_name": "고단백 관리식",
        "description": "단백질 섭취를 우선으로 고려한 식단",
        "focus_key": "nutrition"
    },
    "간편식": {
        "style_id": "easy_cooking",
        "style_name": "간편 조리식",
        "description": "조리 난이도와 시간을 낮게 유지한 식단",
        "focus_key": "difficulty"
    },
    "맛 중심": {
        "style_id": "taste_first",
        "style_name": "취향 맞춤식",
        "description": "선호 카테고리와 재료 취향을 더 많이 반영한 식단",
        "focus_key": "preference"
    }
}


FOCUS_SCORE_LABELS = {
    "budget": "가성비",
    "nutrition": "건강",
    "preference": "취향",
    "difficulty": "조리",
    "diversity": "다양성"
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


def convert_weights_to_style_scores(weights: dict) -> dict:
    """
    0~1 사이의 가중치를 프론트 카드 표시용 1~10 점수로 변환한다.
    """

    return {
        "budget": max(1, round(weights.get("budget", 0) * 10)),
        "nutrition": max(1, round(weights.get("nutrition", 0) * 10)),
        "preference": max(1, round(weights.get("preference", 0) * 10)),
        "difficulty": max(1, round(weights.get("difficulty", 0) * 10)),
        "diversity": max(1, round(weights.get("diversity", 0) * 10)),
    }


def get_candidate_style_metas(profile: dict) -> list[dict]:
    """
    사용자가 선택한 goals를 기반으로 스타일 후보 메타데이터를 가져온다.

    goals가 3개 미만이면, 아직 선택되지 않은 기본 스타일을 추가해
    총 3개 후보가 되도록 한다.
    """

    selected_goals = profile["goals"]

    style_metas = []

    for goal in selected_goals:
        if goal in GOAL_STYLE_META:
            style_metas.append({
                **GOAL_STYLE_META[goal],
                "source_goal": goal
            })

    # 목표가 1~2개인 경우 보조 스타일 추가
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


def build_meal_style_candidates(
    candidate_menus: list[dict],
    profile: dict,
    meal_count_per_day: int,
    sample_period_days: int = 3
) -> dict:
    """
    사용자 목표 기반으로 식단 스타일 후보 3개를 생성한다.

    각 스타일은 전체 목표 base_weights를 유지하되,
    해당 스타일의 focus_key만 살짝 강화한다.
    """

    style_metas = get_candidate_style_metas(profile)

    meal_style_candidates = []

    for index, style_meta in enumerate(style_metas, start=1):
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

        meal_style_candidates.append({
            "style_id": style_meta["style_id"],
            "style_name": style_meta["style_name"],
            "description": style_meta["description"],
            "source_goal": style_meta.get("source_goal"),
            "focus_key": focus_key,
            "focus_label": FOCUS_SCORE_LABELS.get(focus_key, focus_key),
            "style_weights": style_weights,
            "style_scores": convert_weights_to_style_scores(style_weights),
            "sample_plan": sample_plan
        })

    return {
        "meal_style_candidates": meal_style_candidates
    }