from sqlalchemy.orm import Session
from sqlalchemy import extract, func
from sqlalchemy.dialects.sqlite import insert
from datetime import date, timedelta
from app.models.meal import MealPlan
from app.schemas.meal import RecommendationResult

def save_recommendation_result(db: Session, user_id: int, rec_data: RecommendationResult):
    """
    AI의 추천 결과(WeeklyPlan)를 받아 날짜별로 DB에 저장합니다.
    기존 데이터가 있을 경우 업데이트(Upsert)합니다.
    """
    # 1. 식단 시작 날짜 설정 (오늘 기준)
    start_date = date.today()
    
    # 2. weekly_plan 내의 days 리스트 순회
    for day_info in rec_data.weekly_plan.days:
        # AI가 준 day(1, 2, 3...)를 실제 날짜로 변환
        target_date = start_date + timedelta(days=day_info.day - 1)
        
        # 3. 해당 날짜 식단의 요약 정보 계산 (estimated_cost, total_calories)
        daily_meals = day_info.meals
        day_total_cost = sum(m.estimated_cost for m in daily_meals)
        day_total_kcal = sum(m.calories for m in daily_meals)
        
        # 4. Upsert 로직 실행
        # content 필드에는 해당 날짜의 meals 리스트 전체를 dict 형태로 저장합니다.
        stmt = insert(MealPlan).values(
            user_id=user_id,
            meal_date=target_date,
            content=[m.dict() for m in daily_meals],
            estimated_cost=day_total_cost,
            total_calories=day_total_kcal,
            created_at=func.now(),
            updated_at=func.now()
        )

        # 중복 키(user_id, meal_date) 충돌 시 업데이트 설정 (SQLite 기준)
        stmt = stmt.on_conflict_do_update(
            index_elements=['user_id', 'meal_date'], # 모델의 UniqueConstraint 컬럼들
            set_={
                "content": stmt.excluded.content,
                "estimated_cost": stmt.excluded.estimated_cost,
                "total_calories": stmt.excluded.total_calories,
                "updated_at": func.now()
            }
        )
        
        db.execute(stmt)

    db.commit()
    return True

def get_monthly_plans(db: Session, user_id: int, year: int, month: int):
    """
    캘린더 화면(사진 9) 조회를 위해 특정 월의 식단 리스트를 가져옵니다.
    """
    return db.query(MealPlan).filter(
        MealPlan.user_id == user_id,
        extract('year', MealPlan.meal_date) == year,
        extract('month', MealPlan.meal_date) == month
    ).order_by(MealPlan.meal_date.asc()).all()

def get_meal_plan_by_id(db: Session, meal_plan_id: int, user_id: int):
    """
    식단 ID 기반 상세 조회 (상세 페이지용).
    """
    return db.query(MealPlan).filter(
        MealPlan.id == meal_plan_id,
        MealPlan.user_id == user_id
    ).first()