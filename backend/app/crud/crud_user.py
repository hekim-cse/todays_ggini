from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserOnboardingUpdate

def get_user_by_social_id(db: Session, social_id: str, provider: str):
    return db.query(User).filter(User.social_id == social_id, User.provider == provider).first()

def update_user_onboarding(db: Session, user_id: int, obj_in: UserOnboardingUpdate):
    """개인화 설정 정보만 업데이트"""
    # DB에서 해당 유저 찾기
    db_obj = db.query(User).filter(User.id == user_id).first()
    # 전달된 데이터 중 값이 있는 것만 골라내기
    update_data = obj_in.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(db_obj, field, value)
        
    db_obj.is_onboarded = True # 온보딩 완료 상태로 변경
    
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def update_user_selected_style(db: Session, user_id: int, style_id: str) -> User:
    """사용자가 선택한 식단 스타일 ID를 DB에 업데이트합니다."""
    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.selected_style_id = style_id
        db.commit()
        db.refresh(user)
    return user