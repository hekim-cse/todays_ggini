from fastapi import APIRouter, Depends, HTTPException
from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.api.deps import get_current_user, get_db

from app.models.shopping import ShoppingList, ShoppingItem
from app.schemas.shopping import IngredientPriceResponse, ShoppingListResponse, IngredientSelectRequest
from app.models.user import User

router = APIRouter()

@router.get("/ingredients/{ingredient_id}/prices", response_model=IngredientPriceResponse)
async def get_ingredient_market_prices(
    ingredient_id: str,
    db: Session = Depends(get_db)
):
    """
    [화면 10-2] 특정 재료의 마켓별 상세 가격 정보 조회
    - 현재는 Mock 데이터를 반환하며, 이후 크롤링 데이터와 연동됩니다.
    """
    
    # 실제 구현 시: 
    # 1. ingredient_id를 기준으로 캐싱된 마켓 가격 테이블에서 데이터를 조회합니다.
    # 2. 혹은 실시간 크롤링 요청을 보냅니다.

    return {
        "ingredient_id": ingredient_id,
        "ingredient_name": "제철 나물",
        "standard_unit": "100g",
        "image_url": None,
        "e_commerce_prices": {
            "coupang": {
                "delivery_type": "로켓프레시",
                "lowest_price": 1200,
                "product_title": "곰곰 국내산 제철 나물 100g",
                "purchase_link": "https://www.coupang.com/...",
                "is_lowest": True
            },
            "market_kurly": {
                "delivery_type": "샛별배송",
                "lowest_price": 1400,
                "product_title": "[KF365] 제철 나물 100g",
                "purchase_link": "https://www.kurly.com/...",
                "is_lowest": False
            },
            "naver_shopping": {
                "delivery_type": "일반배송",
                "lowest_price": 1300,
                "product_title": "농협 제철 나물 100g",
                "purchase_link": "https://smartstore.naver.com/...",
                "is_lowest": False
            }
        }
    }

@router.post("/shopping-list/items")
async def sync_shopping_items(
    items: List[IngredientSelectRequest],
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    [화면 10-1] 재료 목록에서 '체크된' 항목들만 골라 장바구니에 추가/업데이트합니다.
    """
    # 1. 유저의 고정 장바구니(ShoppingList) 조회 및 생성
    shopping_list = db.query(ShoppingList).filter(ShoppingList.user_id == current_user.id).first()
    if not shopping_list:
        shopping_list = ShoppingList(user_id=current_user.id)
        db.add(shopping_list)
        db.flush()

    added_count = 0
    for item_data in items:
        # 2. 사용자가 체크한 항목인지 확인
        if item_data.is_checked:
            # 장바구니에 이미 있는지 확인 (Upsert)
            existing_item = db.query(ShoppingItem).filter(
                ShoppingItem.list_id == shopping_list.id,
                ShoppingItem.ingredient_id == item_data.ingredient_id
            ).first()

            if existing_item:
                # 이미 있다면 마켓 정보와 가격만 업데이트
                existing_item.market_name = item_data.market_name
                existing_item.price = item_data.price
                existing_item.delivery_type = item_data.delivery_type
                existing_item.is_lowest = item_data.is_lowest
                existing_item.is_checked = True # 다시 체크된 것이므로 True
            else:
                # 없다면 새로 추가
                new_item = ShoppingItem(
                    list_id=shopping_list.id,
                    **item_data.dict()
                )
                db.add(new_item)
            added_count += 1
        else:
            # 3. 만약 체크가 해제되어 들어왔는데, 기존 장바구니에 있었다면 삭제 (선택 사항)
            # 사용자가 리스트에서 체크를 풀고 저장했다면 장바구니에서 빼달라는 의미로 해석 가능
            existing_item = db.query(ShoppingItem).filter(
                ShoppingItem.list_id == shopping_list.id,
                ShoppingItem.ingredient_id == item_data.ingredient_id
            ).first()
            if existing_item:
                db.delete(existing_item)

    db.commit()
    return {"message": "선택된 재료들이 장바구니에 반영되었습니다.", "added_count": added_count}