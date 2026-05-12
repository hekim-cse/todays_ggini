import json
import random
from types import SimpleNamespace

from services.profile.user_input_service import load_sample_users
from services.profile.profile_service import build_user_profile

from services.rag.rag_request_service import (
    build_rag_request,
    calculate_candidate_count,
)
from services.rag.rag_client import request_candidate_menus_from_rag
from services.rag.rag_response_mapper import map_rag_response_to_candidate_menus

from services.style.meal_style_service import build_meal_style_candidates
from services.plan.monthly_plan_test_service import build_monthly_plan_by_random_style


def print_json(title: str, data: dict) -> None:
    """
    제목과 함께 JSON 데이터를 보기 좋게 출력한다.
    """

    print(title)
    print(json.dumps(data, ensure_ascii=False, indent=2))


def save_debug_result(debug_result: dict) -> None:
    """
    추천 흐름에서 오고 가는 주요 JSON 데이터를 debug_result.json으로 저장한다.

    이 파일은 최종 결과용이 아니라,
    Back / Modeling / RAG 사이에서 어떤 데이터가 오고 가는지 확인하기 위한 테스트용 파일이다.
    """

    with open("debug_result.json", "w", encoding="utf-8") as file:
        json.dump(
            debug_result,
            file,
            ensure_ascii=False,
            indent=2
        )


def build_back_to_modeling_sample_request(user_input: dict) -> dict:
    """
    Back에서 Modeling으로 3일치 샘플 식단 추천을 요청하는 JSON 구조를 만든다.
    """

    return {
        "user_id": user_input["user_id"],
        "request_type": "meal_style_candidates",
        "profile": user_input["profile"]
    }


def build_back_to_modeling_monthly_request(
    user_input: dict,
    selected_style: dict
) -> dict:
    """
    Back에서 Modeling으로 월간 식단 생성을 요청하는 JSON 구조를 만든다.

    실제 서비스에서는 사용자가 선택한 selected_style_id를 Back이 전달한다고 가정한다.
    """

    return {
        "user_id": user_input["user_id"],
        "request_type": "monthly_plan",
        "selected_style_id": selected_style["style_id"],
        "profile": user_input["profile"]
    }


def calculate_sample_candidate_count(
    meal_count_per_day: int,
    sample_period_days: int,
    style_count: int = 3,
    buffer_multiplier: int = 3
) -> int:
    """
    3일치 스타일 후보 생성을 위한 RAG 후보 메뉴 개수를 계산한다.

    스타일 후보는 3개가 생성되므로,
    단순히 3일치 식단 수만큼만 후보를 받으면 스타일별 메뉴가 겹칠 가능성이 높다.

    따라서 필요한 식사 수에 스타일 개수와 여유 배수를 곱해
    스타일별로 서로 다른 후보를 선택할 수 있도록 한다.
    """

    return meal_count_per_day * sample_period_days * style_count * buffer_multiplier


def main() -> None:
    """
    모델링 추천 흐름 테스트용 main 함수이다.

    현재 흐름:
    1. 샘플 사용자 중 랜덤 사용자 선택
    2. Back → Modeling 3일치 샘플 추천 요청 JSON 구성
    3. 사용자 입력을 Modeling 내부 프로필로 변환
    4. 3일치 샘플 추천용 RAG 요청 생성
    5. 3일치 샘플 추천용 RAG 응답 로드
    6. RAG 응답을 Modeling 추천용 메뉴 구조로 변환
    7. 3일치 meal_style 후보 생성
    8. 테스트용으로 선택된 meal_style 확인
    9. 월간 식단 생성용 RAG 요청을 별도로 생성
    10. 월간 식단 생성용 RAG 응답 로드
    11. 월간용 RAG 응답을 Modeling 추천용 메뉴 구조로 변환
    12. 월간 후보 메뉴를 기반으로 월간 식단 생성
    13. 전체 데이터 흐름을 debug_result.json으로 저장
    """

    debug_result = {}

    # 1. 샘플 사용자 중 랜덤 사용자 선택
    sample_users = load_sample_users()
    user_input = random.choice(sample_users)

    print(f"랜덤 선택 사용자\n{user_input['user_id']}\n")
    print_json("사용자 입력 원본", user_input)

    # 2. Back → Modeling 3일치 샘플 추천 요청 JSON
    back_to_modeling_sample_request = build_back_to_modeling_sample_request(
        user_input=user_input
    )

    debug_result["back_to_modeling_sample_request"] = back_to_modeling_sample_request

    # 3. 사용자 입력 profile dict를 객체처럼 접근 가능한 형태로 변환
    # build_user_profile 함수는 user_input.period_days 같은 속성 접근 방식을 사용한다.
    profile_input = SimpleNamespace(**user_input["profile"])

    # 4. 사용자 입력을 Modeling 내부 프로필로 변환
    profile = build_user_profile(profile_input)

    print_json("\n사용자 프로필", profile)

    debug_result["modeling_profile"] = profile

    # ============================================================
    # 1단계: 3일 샘플 식단 추천용 RAG 요청
    # ============================================================

    # 5. 3일치 샘플 추천에 필요한 RAG 후보 메뉴 개수 계산
    sample_candidate_count = calculate_sample_candidate_count(
        meal_count_per_day=user_input["profile"]["meal_count_per_day"],
        sample_period_days=user_input["profile"].get("sample_period_days", 3),
        style_count=3,
        buffer_multiplier=3
    )

    # 6. Modeling → RAG 3일치 샘플 후보 요청 JSON 생성
    sample_rag_request = build_rag_request(
        user_input=user_input,
        profile=profile,
        candidate_count=sample_candidate_count
    )

    print_json("\nModeling → RAG 3일 샘플 후보 요청 JSON", sample_rag_request)

    debug_result["modeling_to_rag_sample_request"] = sample_rag_request

    # 7. RAG → Modeling 3일치 샘플 후보 응답 JSON
    # 현재는 실제 RAG 서버 대신 sample_rag_response_200.json을 읽는다.
    sample_rag_response = request_candidate_menus_from_rag(sample_rag_request)

    debug_result["rag_to_modeling_sample_response"] = sample_rag_response

    # 8. 3일 샘플용 RAG 응답을 Modeling 추천 로직용 메뉴 구조로 변환
    mapped_sample_rag_result = map_rag_response_to_candidate_menus(
        sample_rag_response
    )

    debug_result["mapped_sample_candidate_menus"] = mapped_sample_rag_result

    sample_candidate_menus = mapped_sample_rag_result["candidate_menus"]

    # 9. Modeling → Back 3일치 샘플 후보 추천 JSON
    meal_style_response = build_meal_style_candidates(
        user_id=user_input["user_id"],
        profile=profile,
        candidate_menus=sample_candidate_menus,
        sample_period_days=user_input["profile"].get("sample_period_days", 3),
        meal_count_per_day=user_input["profile"]["meal_count_per_day"]
    )

    print_json("\nModeling → Back 3일치 샘플 후보 추천 JSON", meal_style_response)

    debug_result["modeling_to_back_sample_response"] = meal_style_response

    # ============================================================
    # 2단계: 월간 식단 생성용 RAG 요청
    # ============================================================

    # 10. 테스트용 월간 식단 생성
    # 기존 build_monthly_plan_by_random_style 함수는 내부에서 meal_style_response 중 하나를 랜덤 선택한다.
    # 다만 월간 식단에는 샘플용 후보가 아니라 월간용 후보를 넣어야 하므로,
    # 먼저 월간용 RAG 후보를 별도로 요청한다.

    # 월간 식단 생성에 필요한 후보 개수 계산
    monthly_candidate_count = calculate_candidate_count(
        meal_count_per_day=user_input["profile"]["meal_count_per_day"],
        period_days=user_input["profile"].get("period_days", 30),
        buffer_multiplier=3
    )

    # Modeling → RAG 월간 후보 요청 JSON 생성
    monthly_rag_request = build_rag_request(
        user_input=user_input,
        profile=profile,
        candidate_count=monthly_candidate_count
    )

    print_json("\nModeling → RAG 월간 후보 요청 JSON", monthly_rag_request)

    debug_result["modeling_to_rag_monthly_request"] = monthly_rag_request

    # RAG → Modeling 월간 후보 응답 JSON
    monthly_rag_response = request_candidate_menus_from_rag(monthly_rag_request)

    debug_result["rag_to_modeling_monthly_response"] = monthly_rag_response

    # 월간용 RAG 응답을 Modeling 추천 로직용 메뉴 구조로 변환
    mapped_monthly_rag_result = map_rag_response_to_candidate_menus(
        monthly_rag_response
    )

    debug_result["mapped_monthly_candidate_menus"] = mapped_monthly_rag_result

    monthly_candidate_menus = mapped_monthly_rag_result["candidate_menus"]

    # 월간 식단 생성
    # 여기서 핵심은 candidate_menus에 sample_candidate_menus가 아니라
    # monthly_candidate_menus를 넣는 것이다.
    monthly_plan_response = build_monthly_plan_by_random_style(
        user_id=user_input["user_id"],
        candidate_menus=monthly_candidate_menus,
        profile=profile,
        meal_style_response=meal_style_response
    )

    # 월간 식단 생성 결과에서 실제 선택된 스타일을 꺼낸다.
    selected_style_summary = monthly_plan_response["selected_style"]

    debug_result["selected_style"] = selected_style_summary

    # 11. Back → Modeling 월간 식단 추천 요청 JSON
    back_to_modeling_monthly_request = build_back_to_modeling_monthly_request(
        user_input=user_input,
        selected_style=selected_style_summary
    )

    debug_result["back_to_modeling_monthly_request"] = back_to_modeling_monthly_request

    print_json("\n테스트용 랜덤 스타일 선택 → 월간 식단 생성 JSON", monthly_plan_response)

    debug_result["modeling_to_back_monthly_response"] = monthly_plan_response

    # 12. 전체 데이터 흐름 저장
    save_debug_result(debug_result)


if __name__ == "__main__":
    main()