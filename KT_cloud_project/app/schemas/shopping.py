from pydantic import BaseModel, Field
from typing import List, Optional

class MarketPrice(BaseModel):
    delivery_type: str
    lowest_price: int
    product_title: str
    purchase_link: str

class IngredientEcommerce(BaseModel):
    coupang: Optional[MarketPrice] = None
    market_kurly: Optional[MarketPrice] = None
    naver_shopping: Optional[MarketPrice] = None

class IngredientDetailResponse(BaseModel):
    """[재료 상세 창] 각 e커머스별 가격 정보를 포함"""
    ingredient_id: str
    ingredient_name: str
    standard_unit: str
    e_commerce_prices: IngredientEcommerce

class ShoppingItemCreate(BaseModel):
    """[장보기 목록 추가] 체크된 재료들을 추가할 때 사용"""
    ingredient_id: str
    meal_plan_id: int  # 어느 날짜의 식단에서 추가했는지 기록