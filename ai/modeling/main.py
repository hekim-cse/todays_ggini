import json

from schemas.user_profile_schema import UserProfileInput
from services.profile_service import build_user_profile
from services.recommendation_service import recommend_menus


with open("data/sample_menus.json", "r", encoding="utf-8") as file:
    menus = json.load(file)


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


profile = build_user_profile(user_input)

recommendations = recommend_menus(
    menus=menus,
    profile=profile,
    top_n=5
)


print("사용자 프로필")
print(profile)

print("\n추천 결과")
for recommendation in recommendations:
    print(recommendation)