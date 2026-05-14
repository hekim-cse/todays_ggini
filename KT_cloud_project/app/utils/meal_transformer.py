from datetime import datetime, timedelta
from typing import Dict, Any

def transform_ai_plan_to_front(ai_data: Dict[str, Any], target_month_str: str) -> dict:
    """
    모델링 파트의 복잡한 월간 식단 JSON을 프론트엔드 달력용 JSON으로 변환합니다.
    target_month_str: "2026-05" 와 같은 기준 월
    """
    monthly_plan = ai_data.get("monthly_plan", {})
    ai_days = monthly_plan.get("days", [])
    
    # 기준 월의 1일 날짜 객체 생성 (예: 2026-05-01)
    year, month = map(int, target_month_str.split("-"))
    start_date = datetime(year, month, 1)
    
    total_price = 0
    total_calories = 0
    valid_days_count = 0
    
    front_days = []

    for day_data in ai_days:
        # AI 데이터의 day (1, 2, 3...)를 실제 날짜(YYYY-MM-DD)로 변환
        day_offset = day_data.get("day", 1) - 1
        current_date = start_date + timedelta(days=day_offset)
        date_str = current_date.strftime("%Y-%m-%d")
        
        daily_price = day_data.get("total_estimated_cost", 0)
        daily_calories = day_data.get("total_calories", 0)
        
        # 합계 계산
        if daily_price > 0 or daily_calories > 0:
            total_price += daily_price
            total_calories += daily_calories
            valid_days_count += 1
            
        meals_list = []
        for meal in day_data.get("meals", []):
            selected_menu = meal.get("selected_menu", {})
            if selected_menu:
                meals_list.append({
                    "slot": meal.get("meal_order", 1),
                    "meal_id": selected_menu.get("menu_id", ""),
                    "menu_name": selected_menu.get("name", "")
                })
                
        front_days.append({
            "date": date_str,
            "calories_per_day": daily_calories if daily_calories > 0 else None,
            "price_per_day": daily_price if daily_price > 0 else None,
            "meals": meals_list
        })
        
    # 평균 칼로리 계산 (0으로 나누기 방지)
    avg_calories = total_calories // valid_days_count if valid_days_count > 0 else 0

    return {
        "month": target_month_str,
        "duration_days": len(front_days),
        "total_price_per_month": total_price,
        "average_calories_per_month": avg_calories,
        "days": front_days
    }