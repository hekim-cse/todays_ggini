from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserOnboardingUpdate

def get_user_by_social_id(db: Session, social_id: str, provider: str):
    return db.query(User).filter(User.social_id == social_id, User.provider == provider).first()

def create_user(db: Session, provider: str, social_id: str, email: str = None):
    """
    4가지 방식(google, naver, kakao, guest)에 따른 유저 생성
    """
    db_user = User(
        provider=provider,
        social_id=social_id,
        email=email
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

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