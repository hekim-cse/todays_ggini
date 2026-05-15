from services.profile.profile_service import build_user_profile_response

from services.rag.rag_request_service import build_rag_request
from services.rag.rag_client import request_candidate_menus_from_rag
from services.rag.rag_response_mapper import map_rag_response_to_candidate_menus

from services.style.meal_style_service import build_meal_style_candidates
from services.style.style_selection_service import (
    apply_selected_style_to_profile,
    build_selected_style_summary,
)

from services.recommendation.recommendation_service import recommend_menus

from services.plan.period_plan_service import build_period_meal_plan
from services.plan.plan_validation_service import (
    build_style_validation,
    enrich_style_validation,
)
from services.plan.plan_payload_service import build_modeling_to_back_monthly_response


def get_required_user_id(request_data: dict) -> str:
    """
    Back 요청에서 user_id를 안전하게 가져온다.
    """

    user_id = request_data.get("user_id")

    if not user_id:
        raise ValueError("user_id가 없어 모델링 요청을 처리할 수 없습니다.")

    return user_id


def extract_candidate_menus(mapped_rag_response) -> list[dict]:
    """
    RAG mapper 결과에서 candidate_menus 리스트를 안전하게 꺼낸다.

    mapper가 list를 바로 반환하는 경우와
    dict 안에 candidate_menus를 담아 반환하는 경우를 모두 처리한다.
    """

    if isinstance(mapped_rag_response, list):
        return mapped_rag_response

    if isinstance(mapped_rag_response, dict):
        candidate_menus = mapped_rag_response.get("candidate_menus", [])

        if isinstance(candidate_menus, list):
            return candidate_menus

    raise ValueError("RAG 응답에서 candidate_menus 리스트를 찾을 수 없습니다.")


def calculate_style_candidate_count(profile: dict) -> int:
    """
    3일 샘플 스타일 생성을 위한 후보 메뉴 개수를 계산한다.
    """

    sample_period_days = profile.get("sample_period_days", 3)
    meal_count_per_day = profile.get("meal_count_per_day", 1)

    # 스타일 후보는 3개 스타일을 만들어야 하므로 넉넉하게 3배 요청한다.
    return sample_period_days * meal_count_per_day * 3


def calculate_monthly_candidate_count(profile: dict) -> int:
    """
    월간 식단 생성을 위한 후보 메뉴 개수를 계산한다.
    """

    period_days = profile.get("period_days", 30)
    meal_count_per_day = profile.get("meal_count_per_day", 1)

    # 월간 식단은 대체 메뉴까지 필요하므로 3배 후보를 요청한다.
    return period_days * meal_count_per_day * 3


def create_meal_style_candidates(request_data: dict) -> dict:
    """
    Back → Modeling 식단 스타일 후보 생성 진입점이다.

    처리 흐름:
    1. Back에서 받은 사용자 입력을 모델링 profile로 변환한다.
    2. profile을 기반으로 RAG 후보 요청을 생성한다.
    3. RAG 또는 Mock RAG에서 후보 메뉴를 가져온다.
    4. 후보 메뉴를 모델링 내부 candidate_menus 형식으로 변환한다.
    5. 3일치 식단 스타일 후보 3개를 생성한다.
    """

    user_id = get_required_user_id(request_data)

    profile_response = build_user_profile_response(
        request_data=request_data,
    )

    profile = profile_response["profile"]

    candidate_count = calculate_style_candidate_count(
        profile=profile,
    )

    rag_request = build_rag_request(
        user_input=request_data,
        profile=profile,
        candidate_count=candidate_count,
    )

    rag_response = request_candidate_menus_from_rag(
        rag_request=rag_request,
    )

    mapped_rag_response = map_rag_response_to_candidate_menus(
        rag_response=rag_response,
    )

    candidate_menus = extract_candidate_menus(
        mapped_rag_response=mapped_rag_response,
    )

    meal_count_per_day = profile.get("meal_count_per_day", 1)
    sample_period_days = profile.get("sample_period_days", 3)

    return build_meal_style_candidates(
        user_id=user_id,
        candidate_menus=candidate_menus,
        profile=profile,
        meal_count_per_day=meal_count_per_day,
        sample_period_days=sample_period_days,
    )


def create_monthly_plan(request_data: dict) -> dict:
    """
    Back → Modeling 월간 식단 생성 진입점이다.

    처리 흐름:
    1. Back에서 받은 사용자 입력을 모델링 profile로 변환한다.
    2. 사용자가 선택한 스타일을 월간 식단용 profile에 반영한다.
    3. 월간 식단에 필요한 RAG 후보 요청을 생성한다.
    4. RAG 또는 Mock RAG에서 후보 메뉴를 가져온다.
    5. 후보 메뉴를 사용자 조건과 선택 스타일 기준으로 re-rank한다.
    6. MMR 기반으로 기간별 식단을 생성한다.
    7. 스타일 반영 검증과 Back 응답 payload를 생성한다.
    """

    user_id = get_required_user_id(request_data)

    selected_style = request_data.get("selected_style", {})

    if not selected_style:
        raise ValueError("selected_style이 없어 월간 식단을 생성할 수 없습니다.")

    profile_response = build_user_profile_response(
        request_data=request_data,
    )

    base_profile = profile_response["profile"]

    selected_style_summary = build_selected_style_summary(
        selected_style=selected_style,
    )

    monthly_profile = apply_selected_style_to_profile(
        profile=base_profile,
        selected_style=selected_style_summary,
    )

    period_days = monthly_profile.get("period_days", 30)
    meal_count_per_day = monthly_profile.get("meal_count_per_day", 1)

    candidate_count = calculate_monthly_candidate_count(
        profile=monthly_profile,
    )

    rag_request = build_rag_request(
        user_input=request_data,
        profile=monthly_profile,
        candidate_count=candidate_count,
    )

    rag_response = request_candidate_menus_from_rag(
        rag_request=rag_request,
    )

    mapped_rag_response = map_rag_response_to_candidate_menus(
        rag_response=rag_response,
    )

    candidate_menus = extract_candidate_menus(
        mapped_rag_response=mapped_rag_response,
    )

    recommendations = recommend_menus(
        menus=candidate_menus,
        profile=monthly_profile,
        top_n=len(candidate_menus),
    )

    monthly_plan = build_period_meal_plan(
        recommendations=recommendations,
        profile=monthly_profile,
        period_days=period_days,
        meal_count_per_day=meal_count_per_day,
    )

    summary = monthly_plan.get("summary", {})

    base_style_validation = build_style_validation(
        selected_style=selected_style_summary,
        summary=summary,
        profile=monthly_profile,
    )

    style_validation = enrich_style_validation(
        style_validation=base_style_validation,
        selected_style=selected_style_summary,
        summary=summary,
    )

    monthly_plan["style_validation"] = style_validation

    return build_modeling_to_back_monthly_response(
        user_id=user_id,
        selected_style=selected_style_summary,
        base_profile=base_profile,
        monthly_profile=monthly_profile,
        monthly_plan=monthly_plan,
        actual_recommendation_count=len(recommendations),
    )