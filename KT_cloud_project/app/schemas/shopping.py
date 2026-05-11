from pydantic import BaseModel
from typing import List, Optional, Dict

# -------------- 재료 마켓별 가격 비교 상세 전용 스키마 -----------------
class MarketProductDetail(BaseModel):
    delivery_type: str
    lowest_price: int
    product_title: str
    purchase_link: str
    is_lowest: bool

class ECommercePrices(BaseModel):
    coupang: Optional[MarketProductDetail] = None
    market_kurly: Optional[MarketProductDetail] = None
    naver_shopping: Optional[MarketProductDetail] = None

class IngredientPriceResponse(BaseModel):
    ingredient_id: str
    ingredient_name: str
    standard_unit: str
    image_url: Optional[str] = None
    e_commerce_prices: ECommercePrices

# ------------ 장보기 목록 화면 전용 스키마 --------------
class MarketCount(BaseModel):
    market: str
    count: int

class ShoppingItem(BaseModel):
    item_id: str
    ingredient_id: str
    ingredient_name: str
    standard_unit: str
    delivery_type: str
    lowest_price: int
    product_title: str
    purchase_link: str
    is_checked: bool

class MarketGroup(BaseModel):
    market: str
    subtotal: int
    items: List[ShoppingItem]

class ShoppingListResponse(BaseModel):
    total_items: int
    checked_items_count: int
    total_price_per_shopping: int
    market_counts: List[MarketCount]
    market_groups: List[MarketGroup]

# 체크박스를 포함한 재료 상세 정보
class IngredientSelectRequest(BaseModel):
    ingredient_id: str
    ingredient_name: str
    standard_unit: str
    market_name: str
    price: int
    delivery_type: str
    product_title: str
    purchase_link: str
    is_essential: bool = True
    is_checked: bool = True # 체크박스 상태