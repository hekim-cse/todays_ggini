from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.schemas.shopping import RecipeMarketResponse

router = APIRouter()

@router.get("/menus/{meal_id}", response_model=RecipeMarketResponse)
async def get_recipe_with_market_prices(meal_id: str):
    """
    [화면 8, 10-1] 레시피 상세 및 재료별 마켓 최저가 조회 API
    """
    
    # 1. 실제 구현 시에는 DB에서 meal_id에 해당하는 메뉴와 재료 정보를 JOIN하여 가져옵니다.
    # 2. 명세서(image_a3e46f) 기반 Mock 데이터 구성
    
    mock_ingredients = [
        {
            "ingredient_id": "I_001",
            "ingredient_name": "제철 나물",
            "standard_unit": "100g",
            "image_url": None,
            "lowest_price_between_market": {"market": "coupang", "price": 1200},
            "e_commerce_prices": {
                "coupang": {"lowest_price": 1200},
                "market_kurly": {"lowest_price": 1400},
                "naver_shopping": {"lowest_price": 1300}
            }
        },
        {
            "ingredient_id": "I_002",
            "ingredient_name": "계란",
            "standard_unit": "2구",
            "image_url": None,
            "lowest_price_between_market": {"market": "coupang", "price": 1200},
            "e_commerce_prices": {
                "coupang": {"lowest_price": 1200},
                "market_kurly": None,
                "naver_shopping": {"lowest_price": 1300}
            }
        },
        {
            "ingredient_id": "I_003",
            "ingredient_name": "현미밥",
            "standard_unit": "200g",
            "image_url": None,
            "lowest_price_between_market": {"market": "coupang", "price": 1200},
            "e_commerce_prices": {
                "coupang": {"lowest_price": 1200},
                "market_kurly": {"lowest_price": 1400},
                "naver_shopping": {"lowest_price": 1300}
            }
        }
    ]

    return {
        "meal_id": meal_id,
        "menu_name": "제철 나물 비빔밥",
        "calories": 650,
        "price": 3600,
        "image_url": None,
        "video_url": None,
        "required_ingredient_ids": ["I_001", "I_002", "I_003"],
        "ingredients": mock_ingredients
    }