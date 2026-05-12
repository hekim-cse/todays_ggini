import json

from schemas.user_profile_schema import UserProfileInput

from services.profile.profile_service import build_user_profile
from services.profile.user_input_service import select_random_user_input

from services.rag.rag_request_service import (
    build_rag_request,
    calculate_candidate_count,
)

from services.rag.rag_client import request_candidate_menus_from_rag
from services.rag.rag_response_mapper import map_rag_response_to_candidate_menus

from services.style.meal_style_service import build_meal_style_candidates
from services.plan.monthly_plan_test_service import build_monthly_plan_by_random_style


USE_MOCK_RAG = True


selected_user = select_random_user_input()

user_id = selected_user["user_id"]
user_profile_data = selected_user["profile"]

user_input = UserProfileInput(**user_profile_data)

profile = build_user_profile(user_input)

sample_period_days = user_profile_data.get("sample_period_days", 3)

candidate_count = calculate_candidate_count(
    meal_count_per_day=user_input.meal_count_per_day,
    period_days=sample_period_days
)

rag_request = build_rag_request(
    user_input=user_input,
    profile=profile,
    candidate_count=candidate_count
)

rag_response = request_candidate_menus_from_rag(
    rag_request=rag_request
)

candidate_menus = rag_response["candidate_menus"]

meal_style_result = build_meal_style_candidates(
    user_id=user_id,
    candidate_menus=candidate_menus,
    profile=profile,
    meal_count_per_day=user_input.meal_count_per_day,
    sample_period_days=sample_period_days
)

monthly_plan = build_monthly_plan_by_random_style(
    user_id=user_id,
    candidate_menus=candidate_menus,
    profile=profile,
    meal_style_response=meal_style_result
)

print("랜덤 선택 사용자")
print(user_id)

print("\n사용자 입력 원본")
print(json.dumps(selected_user, ensure_ascii=False, indent=2))

print("\n사용자 프로필")
print(json.dumps(profile, ensure_ascii=False, indent=2))

print("\nModeling → RAG 요청 JSON")
print(json.dumps(rag_request, ensure_ascii=False, indent=2))

print("\nModeling → Back 3일치 샘플 후보 추천 JSON")
print(json.dumps(meal_style_result, ensure_ascii=False, indent=2))

print("테스트용 랜덤 스타일 선택 → 월간 식단 생성 JSON")
print(json.dumps(monthly_plan, ensure_ascii=False, indent=2))