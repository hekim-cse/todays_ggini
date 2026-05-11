from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified
from datetime import date, datetime
import uuid
import calendar

from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.models.meal import MealPlan
from app.schemas.meal import (DailyMealDetailResponse, RecommendationResult, MealGenerateResponse, MealConfirmResponse,
                              CalendarResponse, MealSwapResponse, MealSwapRequest, MenuUpdateRequest, AlternativeMenuResponse)
from app.crud import crud_meal
from app.utils.image_search import get_food_image_url
from app.utils.ai_client import request_ai_meal_plan

router = APIRouter()

# ---------------------------  프론트엔드 호출용 API ---------------------------------
@router.post("/generate", response_model=MealGenerateResponse, status_code=status.HTTP_202_ACCEPTED)
async def generate_meal_plans_trigger(
    current_user: User = Depends(get_current_user)
):
    """
    [화면 6] 프로필 기반 식단 생성 트리거
    JSON 초안에 맞춰 job_id와 진행 단계 정보를 반환합니다.
    """
    
    # 1. 고유 작업 ID 생성
    job_id = f"job_{uuid.uuid4().hex[:8]}"
    
    # 2. 실제 구현 시: Celery나 FastAPI BackgroundTasks를 사용하여 
    # 비동기로 crud_meal.save_recommendation_result를 실행해야 합니다.
    # 지금은 흐름을 맞추기 위해 즉시 작업 정보를 반환합니다.
    
    return {
        "job_id": job_id,
        "estimated_seconds": 10,
        "stages": ["프로필 분석", "식단 후보 생성", "가격 비교", "최적 조합 선정"]
    }

@router.post("/confirm", response_model=MealConfirmResponse)
def confirm_meal_plan(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    [화면 9] 생성된 30일 식단을 최종 확정하고 요약 정보를 반환합니다.
    """
    # 1. 해당 유저의 가장 최근 생성된(혹은 임시 상태인) 식단 리스트 조회
    # (실제 서비스에서는 is_confirmed 등의 상태 값을 활용할 수 있습니다)
    plans = db.query(MealPlan).filter(
        MealPlan.user_id == current_user.id
    ).order_by(MealPlan.meal_date.asc()).all()

    if not plans:
        raise HTTPException(status_code=404, detail="확정할 식단 내역이 없습니다.")

    # 2. 명세서 규격에 맞는 요약 데이터 계산
    start_date = plans[0].meal_date
    end_date = plans[-1].meal_date
    duration = (end_date - start_date).days + 1
    
    total_price = sum(p.estimated_cost for p in plans if p.estimated_cost)
    total_calories = sum(p.total_calories for p in plans if p.total_calories)
    avg_calories = total_calories // duration if duration > 0 else 0

    # 3. 응답 반환
    return {
        "plan_id": f"plan_{current_user.id}_{start_date.strftime('%Y%m%d')}",
        "start_date": start_date,
        "end_date": end_date,
        "duration_days": duration,
        "total_price_per_plan": total_price,
        "average_calories_per_plan": avg_calories,
        "generated_at": datetime.now() # 혹은 DB의 생성일시 컬럼 사용
    }

@router.get("/calendar", response_model=CalendarResponse)
def get_monthly_calendar(
    month: str, # "2026-04" 형식
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    월간 캘린더를 조회합니다.
    """
    # 1. 해당 월의 시작일과 마지막일 계산
    year, mon = map(int, month.split("-"))
    last_day = calendar.monthrange(year, mon)[1]
    start_date = date(year, mon, 1)
    end_date = date(year, mon, last_day)

    # 2. DB에서 해당 기간의 식단 조회
    plans = db.query(MealPlan).filter(
        MealPlan.user_id == current_user.id,
        MealPlan.meal_date >= start_date,
        MealPlan.meal_date <= end_date
    ).all()
    
    plan_dict = {p.meal_date: p for p in plans}

    # 3. 1일부터 말일까지 루프를 돌며 days 배열 생성
    days_list = []
    total_price = 0
    total_cal = 0
    meal_count = 0

    for day in range(1, last_day + 1):
        curr_date = date(year, mon, day)
        plan = plan_dict.get(curr_date)
        
        if plan:
            # DB의 content JSON에서 필요한 필드만 추출
            extracted_meals = []
            for meal in plan.content:  # content는 리스트 형태의 상세 정보
                extracted_meals.append({
                    "slot": meal.get("meal_order"),
                    "meal_id": str(meal.get("menu_id")),
                    "menu_name": meal.get("name")
            })
            # 식단이 있는 날
            day_data = {
                "date": curr_date,
                "calories_per_day": plan.total_calories,
                "price_per_day": plan.estimated_cost,
                "meals": extracted_meals
            }
            total_price += plan.estimated_cost
            total_cal += plan.total_calories
            meal_count += 1
        else:
            # 식단이 없는 날 (명세서 규격 준수)
            day_data = {
                "date": curr_date,
                "calories_per_day": None,
                "price_per_day": None,
                "meals": []
            }
        days_list.append(day_data)

    return {
        "month": month,
        "duration_days": meal_count,
        "total_price_per_month": total_price,
        "average_calories_per_month": total_cal // meal_count if meal_count > 0 else 0,
        "days": days_list
    }

@router.get("/{date}", response_model=DailyMealDetailResponse)
async def get_daily_meal_detail(
    date: date, # YYYY-MM-DD 형식의 경로 파라미터
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    [화면 10] 일일 식단 상세 정보를 조회합니다.
    """
    # 1. 해당 유저와 날짜에 맞는 식단 조회
    plan = db.query(MealPlan).filter(
        MealPlan.user_id == current_user.id,
        MealPlan.meal_date == date
    ).first()

    if not plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"{date}에 해당하는 식단 데이터가 없습니다."
        )

    # 2. DB의 content(JSON) 데이터 정제 및 타입 변환
    detail_meals = []
    for item in plan.content:
        menu_name = item.get("name")
        category = item.get("category")
        img_url = await get_food_image_url(menu_name, category)

        detail_meals.append({
            "slot": item.get("meal_order"),
            "meal_id": str(item.get("menu_id")),
            "menu_name": menu_name,
            "calories": item.get("calories", 0),
            "price": item.get("estimated_cost", 0),
            "image_url": img_url # Pixabay API를 호출하여 이미지를 가져옴
        })

    # 3. 명세서 규격에 맞춘 결과 반환
    return {
        "date": plan.meal_date,
        "calories_per_day": plan.total_calories,
        "price_per_day": plan.estimated_cost,
        "meals": detail_meals
    }

@router.patch("/{date}/swap", response_model=MealSwapResponse)
def swap_meal_plans(
    date: date,
    request: MealSwapRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    두 날짜의 식단을 스왑합니다.
    """
    date1 = date
    date2 = request.with_date

    if date1 == date2:
        raise HTTPException(status_code=400, detail="동일한 날짜는 스왑할 수 없습니다.")

    # 1. 두 날짜 데이터 조회
    plan1 = db.query(MealPlan).filter(MealPlan.user_id == current_user.id, MealPlan.meal_date == date1).first()
    plan2 = db.query(MealPlan).filter(MealPlan.user_id == current_user.id, MealPlan.meal_date == date2).first()

    if not plan1 and not plan2:
        raise HTTPException(status_code=404, detail="스왑할 데이터가 없습니다.")

    # 2. 데이터 교환 (트랜잭션)
    try:
        # 임시 저장을 위한 데이터 추출
        content1, cost1, cal1 = (plan1.content, plan1.estimated_cost, plan1.total_calories) if plan1 else ([], 0, 0)
        content2, cost2, cal2 = (plan2.content, plan2.estimated_cost, plan2.total_calories) if plan2 else ([], 0, 0)

        # Plan 1 업데이트 (내용 교체)
        if plan1:
            plan1.content, plan1.estimated_cost, plan1.total_calories = content2, cost2, cal2
        
        # Plan 2 업데이트 (내용 교체)
        if plan2:
            plan2.content, plan2.estimated_cost, plan2.total_calories = content1, cost1, cal1

        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"스왑 실패: {str(e)}")

    # 3. 명세서에 맞춘 응답 구성 (요약된 meals 정보 포함)
    def format_day(d, p_content, p_cal, p_cost):
        return {
            "date": d,
            "calories_per_day": p_cal if p_content else None,
            "price_per_day": p_cost if p_content else None,
            "meals": [
                {
                    "slot": m.get("meal_order"),
                    "meal_id": str(m.get("menu_id")),
                    "menu_name": m.get("name")
                } for m in p_content
            ]
        }

    return {
        "swapped": [
            format_day(date1, content2, cal2, cost2),
            format_day(date2, content1, cal1, cost1)
        ]
    }

@router.put("/{date}/menus/{slot}", response_model=DailyMealDetailResponse)
async def update_specific_menu_slot(
    date: date,
    slot: int,
    request: MenuUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    [화면 10-3] 특정 날짜의 특정 슬롯(아침/점심/저녁) 메뉴를 변경합니다.
    """
    # 1. 기존 식단 조회
    plan = db.query(MealPlan).filter(
        MealPlan.user_id == current_user.id,
        MealPlan.meal_date == date
    ).first()

    if not plan:
        raise HTTPException(status_code=404, detail="해당 날짜의 식단이 존재하지 않습니다.")

    # 2. 새로운 메뉴 정보 조회 (AI 추천 대안 리스트 등에서 선택된 데이터라고 가정)
    # 실제 구현 시에는 전체 메뉴 메타데이터 테이블에서 new_meal_id로 정보를 가져와야 합니다.
    # 여기서는 예시를 위해 새로운 메뉴 데이터를 정의합니다.
    new_menu_data = {
        "meal_order": slot, 
        "menu_id": 111, 
        "name": "야채 볶음밥",
        "category": "한식", 
        "final_score": 95.5, 
        "estimated_cost": 4500,
        "calories": 550, 
        "protein": 22.0,
        "ingredients": ["두부", "밥", "상추"],
        "ingredient_groups": ["식물성 단백질", "채소"],
        "recipe": {
            "serving_size": 1, 
            "cooking_time": 15,
            "steps": ["재료 손질", "비비기"],
            "required_ingredients": ["두부", "밥"],
            "optional_ingredients": [], 
            "substitution_ingredients": {}
        },
        "scores": {
            "budget": 100, "nutrition": 90, "preference": 95, 
            "difficulty": 100, "diversity": 100
        }
    }

    # 3. content 내의 특정 슬롯 교체
    target_index = slot - 1

    try:
        # 기존 메뉴 백업 (통계 계산용)
        old_menu = plan.content[target_index]
        
        # 2. 전체 순회 없이 해당 인덱스만 교체
        plan.content[target_index] = new_menu_data
        
        # 3. 전체 합산 대신 차이만큼만 가감하여 통계 갱신 (성능 이점)
        plan.total_calories += (new_menu_data["calories"] - old_menu.get("calories", 0))
        plan.estimated_cost += (new_menu_data["estimated_cost"] - old_menu.get("estimated_cost", 0))
        
        # SQLAlchemy에게 JSON 내부가 변경되었음을 명시적으로 알림
        flag_modified(plan, "content")
        
        db.commit()
    except IndexError:
        raise HTTPException(status_code=400, detail="유효하지 않은 슬롯 번호입니다.")

    # 5. 응답 구성 (이미지 포함)
    detail_meals = []
    for item in plan.content:
        img_url = await get_food_image_url(item.get("name"),item.get("category"))
        detail_meals.append({
            "slot": item.get("meal_order"),
            "meal_id": str(item.get("menu_id")),
            "menu_name": item.get("name"),
            "calories": item.get("calories", 0),
            "price": item.get("estimated_cost", 0),
            "image_url": img_url
        })

    return {
        "date": plan.meal_date,
        "calories_per_day": plan.total_calories,
        "price_per_day": plan.estimated_cost,
        "meals": detail_meals
    }

# @router.get("/menus/{meal_id}/alternatives", response_model=AlternativeMenuResponse)
# async def get_meal_alternatives(
#     meal_id: str,
#     db: Session = Depends(get_db),
#     current_user: User = Depends(get_current_user)
# ):
#     """
#     [화면 10-3] 메뉴 변경용 추천 대안 조회 API
#     """
    
#     # 1. DB에서 현재 메뉴 정보 탐색 (식단 계획 내 JSON 데이터 파싱)
#     # 실제로는 meal_id가 content 리스트 안에 있으므로 전체 날짜를 뒤져야 할 수 있습니다.
#     # 여기서는 시연을 위해 간단한 조회 로직으로 구성합니다.
#     meal_plan = db.query(MealPlan).filter(
#         MealPlan.user_id == current_user.id
#         # 식단 ID를 찾는 로직이 필요 (예시)
#     ).first()

#     if not meal_plan:
#         raise HTTPException(status_code=404, detail="식단 정보를 찾을 수 없습니다.")

#     # 2. 명세서 기반 Current Meal 구성 (Mock)
#     current_meal = {
#         "meal_id": meal_id,
#         "menu_name": "볶음밥",
#         "calories": 650,
#         "price": 3600,
#         "image_url": await get_food_image_url("볶음밥"),
#         "date": meal_plan.meal_date,
#         "slot": 1
#     }

#     # 3. 명세서 기반 Alternatives 구성 (Mock)
#     alternatives = [
#         {"meal_id": "M_101", "menu_name": "두부 김치덮밥", "calories": 620, "price": 6500},
#         {"meal_id": "M_102", "menu_name": "야채 볶음밥", "calories": 580, "price": 5800},
#         {"meal_id": "M_103", "menu_name": "닭가슴살 샐러드", "calories": 450, "price": 9200},
#         {"meal_id": "M_104", "menu_name": "참치 김밥", "calories": 550, "price": 4500},
#     ]

#     # 이미지 URL 매핑
#     for alt in alternatives:
#         alt["image_url"] = await get_food_image_url(alt["menu_name"])

#     return {
#         "current_meal": current_meal,
#         "alternatives": alternatives
#     }



# ------------------------------- AI 모델 서버 호출용 API(Modeling -> Back) ----------------------------------
# # AI 모델 서버 주소 (환경 변수 권장)
# AI_MODEL_SERVER_URL = "http://ai-modeling-server/predict"

@router.post("/generate_sample_data_three_days")
async def generate_initial_meal_plan(
    sample_period_days: int = 3, # 명세서 예시의 3일치 샘플
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    사용자의 페르소나를 기반으로 모델링 파트에 식단 생성을 요청합니다.
    """
    
    # 1. DB의 User 테이블에서 페르소나 데이터 추출 및 가공
    # 명세서의 규격에 맞게 변환합니다.
    ai_payload = {
        "user_id": f"user_{current_user.id:03d}", # user_001 형식
        "request_type": "meal_style_candidates",
        "profile": {
            "goals": current_user.purpose, # List[string]
            "sample_period_days": sample_period_days,
            "monthly_budget": current_user.monthly_budget,
            "meal_count_per_day": current_user.meals_per_day,
            "cooking_skill": current_user.cooking_skill,
            "preferred_categories": current_user.preferred_style, # 한식, 분식 등
            "diversity_level": current_user.diversity_level,
            "ingredient_preferences": current_user.preferred_ingredients,
            "allergy_ingredients": current_user.excluded_ingredients # 제외 재료
        }
    }

    # 2. 모델링 파트에 데이터 전송 (AI 서버 호출)
    ai_response = await request_ai_meal_plan(ai_payload)

    if not ai_response:
        # AI 서버 응답 실패 시 Mock 데이터나 에러 반환
        raise HTTPException(status_code=500, detail="AI 모델 서버로부터 응답을 받을 수 없습니다.")

    # 3. AI가 준 결과를 DB(MealPlan 테이블)에 저장하는 로직
    # (이후 저장 로직 추가 필요)
    
    return {
        "message": "식단 생성 요청이 성공적으로 전달되었습니다.",
        "sent_data": ai_payload, # 디버깅용
        "ai_result": ai_response
    }

@router.post("/generate_sample", status_code=status.HTTP_201_CREATED)
async def generate_meal_plan(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    [Mock 테스트 버전] 외부 AI 서버 없이 로컬 데이터를 사용하여 파이프라인 검증
    """
    # 1. (생략) 남은 일수 계산 로직 등은 유지
    
    # 2. AI 서버 통신 대신 Mock 데이터 정의 (Modeling -> Back 포맷)
    mock_ai_response = {
        "user_id": f"user_{current_user.id}",
        "summary": {
            "goals": current_user.purpose,
            "year": 2026,
            "month": 5,
            "days_remaining": 28, # 모델링 파트 요청 반영
            "meal_budget": 5000,
            "meal_count_per_day": current_user.meals_per_day,
            "required_meal_count": 6,
            "available_recommendation_count": 6,
            "diversity_level": current_user.diversity_level,
            "diversity_penalty_strength": 0.1,
            "warnings": []
        },
        "weekly_plan": {
            "period_days": 3,
            "meal_count_per_day": current_user.meals_per_day,
            "days": [
                {
                    "day": 1,
                    "meals": [
                        {
                            "meal_order": 1, "menu_id": 101, "name": "두부 비빔밥",
                            "category": "한식", "final_score": 95.5, "estimated_cost": 4500,
                            "calories": 550, "protein": 22.0,
                            "ingredients": ["두부", "밥", "상추"],
                            "ingredient_groups": ["식물성 단백질", "채소"],
                            "recipe": {
                                "serving_size": 1, "cooking_time": 15,
                                "steps": ["재료 손질", "비비기"],
                                "required_ingredients": ["두부", "밥"],
                                "optional_ingredients": [], "substitution_ingredients": {}
                            },
                            "scores": {"budget": 100, "nutrition": 90, "preference": 95, "difficulty": 100, "diversity": 100}
                        },
                        {
                            "meal_order": 2, "menu_id": 102, "name": "불고기덮밥",
                            "category": "한식", "final_score": 96.5, "estimated_cost": 8000,
                            "calories": 650, "protein": 12.0,
                            "ingredients": ["불고기", "밥", "버섯"],
                            "ingredient_groups": ["식물성 단백질", "채소"],
                            "recipe": {
                                "serving_size": 1, "cooking_time": 15,
                                "steps": ["재료 손질", "비비기"],
                                "required_ingredients": ["불고기", "밥"],
                                "optional_ingredients": [], "substitution_ingredients": {}
                            },
                            "scores": {"budget": 100, "nutrition": 90, "preference": 95, "difficulty": 100, "diversity": 100}
                        },
                        {
                            "meal_order": 3, "menu_id": 103, "name": "크림 파스타",
                            "category": "양식", "final_score": 93.5, "estimated_cost": 6000,
                            "calories": 700, "protein": 15.0,
                            "ingredients": ["우유", "면", "양파"],
                            "ingredient_groups": ["식물성 단백질", "채소"],
                            "recipe": {
                                "serving_size": 1, "cooking_time": 15,
                                "steps": ["재료 손질", "비비기"],
                                "required_ingredients": ["우유", "면"],
                                "optional_ingredients": [], "substitution_ingredients": {}
                            },
                            "scores": {"budget": 100, "nutrition": 90, "preference": 95, "difficulty": 100, "diversity": 100}
                        } 
                    ]
                },
                {
                    "day": 2,
                    "meals": [
                        {
                            "meal_order": 1, "menu_id": 104, "name": "김치 볶음밥",
                            "category": "한식", "final_score": 95.5, "estimated_cost": 5000,
                            "calories": 550, "protein": 22.0,
                            "ingredients": ["김치", "밥", "설탕"],
                            "ingredient_groups": ["식물성 단백질", "채소"],
                            "recipe": {
                                "serving_size": 1, "cooking_time": 15,
                                "steps": ["재료 손질", "비비기"],
                                "required_ingredients": ["김치", "밥"],
                                "optional_ingredients": [], "substitution_ingredients": {}
                            },
                            "scores": {"budget": 100, "nutrition": 90, "preference": 95, "difficulty": 100, "diversity": 100}
                        },
                        {
                            "meal_order": 2, "menu_id": 105, "name": "떡볶이",
                            "category": "한식", "final_score": 96.5, "estimated_cost": 3500,
                            "calories": 650, "protein": 12.0,
                            "ingredients": ["떡", "고추장", "어묵"],
                            "ingredient_groups": ["식물성 단백질", "채소"],
                            "recipe": {
                                "serving_size": 1, "cooking_time": 15,
                                "steps": ["재료 손질", "비비기"],
                                "required_ingredients": ["떡", "어묵"],
                                "optional_ingredients": [], "substitution_ingredients": {}
                            },
                            "scores": {"budget": 100, "nutrition": 90, "preference": 95, "difficulty": 100, "diversity": 100}
                        },
                        {
                            "meal_order": 3, "menu_id": 106, "name": "닭가슴살 샐러드",
                            "category": "양식", "final_score": 93.5, "estimated_cost": 3000,
                            "calories": 700, "protein": 15.0,
                            "ingredients": ["닭가슴살", "상추"],
                            "ingredient_groups": ["식물성 단백질", "채소"],
                            "recipe": {
                                "serving_size": 1, "cooking_time": 15,
                                "steps": ["재료 손질", "비비기"],
                                "required_ingredients": ["상추", "닭가슴살"],
                                "optional_ingredients": [], "substitution_ingredients": {}
                            },
                            "scores": {"budget": 100, "nutrition": 90, "preference": 95, "difficulty": 100, "diversity": 100}
                        } 
                    ]
                }
            ]
        }
    }

    # 3. 스키마 검증 (실제 운영 코드와 동일하게 유지)
    try:
        validated_result = RecommendationResult(**mock_ai_response)
    except Exception as e:
        raise HTTPException(status_code=422, detail=f"Mock 데이터 검증 실패: {str(e)}")

    # 4. DB 저장 실행
    crud_meal.save_recommendation_result(db, user_id=current_user.id, rec_data=validated_result)

    return {"message": "Mock 데이터를 이용한 식단 생성이 완료되었습니다."}

# @router.post("/generate", status_code=status.HTTP_201_CREATED)
# async def generate_monthly_meal_plan(
#     db: Session = Depends(get_db),
#     current_user: User = Depends(get_current_user)
# ):
#     """
#     사용자 프로필을 AI 모델에 전달하고, 생성된 통합 식단 데이터를 DB에 저장합니다.
#     """

#     today = date.today()
    
#     # [로직 추가] 해당 월의 마지막 날짜 구하기
#     # calendar.monthrange(연도, 월) -> (시작 요일, 마지막 날짜) 반환
#     _, last_day = calendar.monthrange(today.year, today.month)
    
#     # 남은 일 수 계산 (오늘 포함: 마지막 날 - 오늘 날짜 + 1)
#     days_remaining = last_day - today.day + 1

#     # 1. AI 파트에 전달할 프로필 데이터 구성 (Back -> Modeling JSON 규격)
#     request_body = {
#         "user_id": f"user_{current_user.id}",
#         "profile": {
#             "goals": current_user.purposes,
#             "year": date.today().year,
#             "month": date.today().month,
#             "days_remaining": days_remaining,
#             "monthly_budget": current_user.monthly_budget,
#             "meal_count_per_day": current_user.meals_per_day,
#             "cooking_skill": current_user.cooking_skill,
#             "preferred_categories": current_user.preferred_categories,
#             "diversity_level": current_user.diversity_level,
#             "ingredient_preferences": current_user.preferred_ingredients,
#             "allergy_ingredients": current_user.excluded_ingredients
#         }
#     }

#     # 2. Modeling 파트에 추천 요청 전송
#     async with httpx.AsyncClient() as client:
#         try:
#             response = await client.post(AI_MODEL_SERVER_URL, json=request_body, timeout=60.0)
#             response.raise_for_status()
#             ai_response_data = response.json()
#         except httpx.HTTPError as e:
#             raise HTTPException(status_code=500, detail=f"AI 모델 서버 통신 실패: {str(e)}")

#     # 3. AI 응답 데이터를 스키마로 검증 (Modeling -> Back JSON 규격)
#     try:
#         validated_result = RecommendationResult(**ai_response_data)
#     except Exception as e:
#         raise HTTPException(status_code=422, detail=f"AI 응답 데이터 형식이 올바르지 않습니다: {str(e)}")

#     # 4. DB 저장 (CRUD 호출)
#     success = crud_meal.save_recommendation_result(db, user_id=current_user.id, rec_data=validated_result)
    
#     if not success:
#         raise HTTPException(status_code=500, detail="식단 저장 중 오류가 발생했습니다.")

#     return {"message": "한 달 식단 생성이 완료되었습니다."}