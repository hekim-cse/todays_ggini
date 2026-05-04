import json

from schemas.user_profile_schema import UserProfileInput
from services.profile_service import build_user_profile
from services.rag_request_service import (
    build_rag_request,
    calculate_candidate_count,
)
from services.rag_client import fetch_candidate_menus
from services.user_input_service import select_random_user_input
from services.meal_style_service import build_meal_style_candidates


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

rag_response = fetch_candidate_menus(
    rag_request=rag_request,
    use_mock=USE_MOCK_RAG
)

candidate_menus = rag_response["candidate_menus"]

meal_style_result = build_meal_style_candidates(
    user_id=user_id,
    candidate_menus=candidate_menus,
    profile=profile,
    meal_count_per_day=user_input.meal_count_per_day,
    sample_period_days=sample_period_days
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