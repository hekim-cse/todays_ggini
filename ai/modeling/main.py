import json
from services.meal_style_service import build_meal_style_candidates
from schemas.user_profile_schema import UserProfileInput
from services.profile_service import build_user_profile
from services.rag_request_service import (
    build_rag_request,
    calculate_candidate_count,
)
from services.rag_client import fetch_candidate_menus
from services.recommendation_service import recommend_menus
from services.weekly_plan_service import build_weekly_meal_plan
from services.user_input_service import select_random_user_input


# 1. 기본 설정
PERIOD_DAYS = 7
USE_MOCK_RAG = True


# 2. 여러 사용자 mock 데이터 중 하나를 랜덤으로 선택
selected_user = select_random_user_input()

user_id = selected_user["user_id"]
user_profile_data = selected_user["profile"]


# 3. 선택된 사용자 입력값을 Pydantic schema로 검증
user_input = UserProfileInput(**user_profile_data)


# 4. 사용자 입력값을 모델링용 프로필로 변환
profile = build_user_profile(user_input)


# 5. 필요한 후보 메뉴 개수 계산
candidate_count = calculate_candidate_count(
    meal_count_per_day=user_input.meal_count_per_day,
    period_days=PERIOD_DAYS
)


# 6. Modeling → RAG 요청 JSON 생성
rag_request = build_rag_request(
    user_input=user_input,
    profile=profile,
    candidate_count=candidate_count
)


# 7. RAG 후보 메뉴 가져오기
# 현재는 USE_MOCK_RAG=True이므로 sample_menus.json에서 가져온다.
rag_response = fetch_candidate_menus(
    rag_request=rag_request,
    use_mock=USE_MOCK_RAG
)


# 8. RAG 응답에서 candidate_menus만 꺼내기
candidate_menus = rag_response["candidate_menus"]


# 9. 후보 메뉴에 대해 모델링 점수 계산
recommendations = recommend_menus(
    menus=candidate_menus,
    profile=profile,
    top_n=candidate_count
)


# 식단 스타일 후보 3개 생성

meal_style_result = build_meal_style_candidates(

    candidate_menus=candidate_menus,

    profile=profile,

    meal_count_per_day=user_input.meal_count_per_day,

    sample_period_days=3

)

print("랜덤 선택 사용자")

print(user_id)

print("\n사용자 입력 원본")

print(json.dumps(selected_user, ensure_ascii=False, indent=2))

print("\n사용자 프로필")

print(json.dumps(profile, ensure_ascii=False, indent=2))

print("\nModeling → RAG 요청 JSON")

print(json.dumps(rag_request, ensure_ascii=False, indent=2))

print("\n식단 스타일 후보 3개")

print(json.dumps(meal_style_result, ensure_ascii=False, indent=2))