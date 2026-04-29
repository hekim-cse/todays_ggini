import json

from schemas.user_profile_schema import UserProfileInput
from services.profile_service import build_user_profile
from services.rag_request_service import (
    build_rag_request,
    calculate_candidate_count,
)
from services.rag_client import fetch_candidate_menus
from services.recommendation_service import recommend_menus
from services.weekly_plan_service import build_weekly_meal_plan


# 1. 기본 설정
PERIOD_DAYS = 7
USE_MOCK_RAG = True


# 2. 사용자 입력값 생성
user_input = UserProfileInput(
    goals=["식비 절약", "고단백", "간편식"],
    year=2026,
    month=1,
    monthly_budget=300000,
    meal_count_per_day=2,
    cooking_skill=2,
    preferred_categories=["한식", "분식"],
    diversity_level="높음",
    ingredient_preferences={
        "육류": 4,
        "해산물류": 2,
        "식물성 단백질류": 5,
        "채소류": 4,
        "계란·유제품류": 3
    },
    allergy_ingredients=["계란"]
)


# 3. 사용자 입력값을 모델링용 프로필로 변환
profile = build_user_profile(user_input)


# 4. 필요한 후보 메뉴 개수 계산
candidate_count = calculate_candidate_count(
    meal_count_per_day=user_input.meal_count_per_day,
    period_days=PERIOD_DAYS
)


# 5. Modeling → RAG 요청 JSON 생성
rag_request = build_rag_request(
    user_input=user_input,
    profile=profile,
    candidate_count=candidate_count
)


# 6. RAG 후보 메뉴 가져오기
# 현재는 USE_MOCK_RAG=True이므로 sample_menus.json에서 가져온다.
# 나중에 RAG가 완성되면 USE_MOCK_RAG=False로 바꾸고 rag_client.py만 연결하면 된다.
rag_response = fetch_candidate_menus(
    rag_request=rag_request,
    use_mock=USE_MOCK_RAG
)


# 7. RAG 응답에서 candidate_menus만 꺼내기
candidate_menus = rag_response["candidate_menus"]


# 8. 후보 메뉴에 대해 모델링 점수 계산
recommendations = recommend_menus(
    menus=candidate_menus,
    profile=profile,
    top_n=candidate_count
)


# 9. 최종 추천 결과를 7일치 식단으로 구성
weekly_plan = build_weekly_meal_plan(
    recommendations=recommendations,
    meal_count_per_day=user_input.meal_count_per_day,
    period_days=PERIOD_DAYS
)


# 10. 출력
print("사용자 프로필")
print(json.dumps(profile, ensure_ascii=False, indent=2))

print("\nModeling → RAG 요청 JSON")
print(json.dumps(rag_request, ensure_ascii=False, indent=2))

print("\nRAG → Modeling 응답 JSON")
print(json.dumps(rag_response, ensure_ascii=False, indent=2))

print("\n추천 결과")
print(json.dumps(recommendations, ensure_ascii=False, indent=2))

print("\n7일치 식단 구성 결과")
print(json.dumps(weekly_plan, ensure_ascii=False, indent=2))