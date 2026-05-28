from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy.orm import Session
from typing import Any

from app.api.deps import get_db, get_current_user
from app.schemas.user import UserResponse, UserOnboardingUpdate, UserInfo, NicknameUpdateRequest, ProfileImageUpdateRequest
from app.crud import crud_user
from app.models.user import User

router = APIRouter()

# --------------------------- 온보딩 업데이트 API ---------------------------------    
@router.patch("/onboarding", response_model=UserResponse)
def update_onboarding(
    obj_in: UserOnboardingUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)) -> Any:
    """
    [온보딩] 유저의 온보딩 정보(페르소나, 예산 등 8개 항목)를 업데이트합니다.\
    최초 입력 시에는 is_onboarded를 True로 바꾸고, 이후에는 정보만 갱신합니다.
    """
    
    return crud_user.update_user_onboarding(db, user_id=current_user.id, obj_in=obj_in)

# ----------------- 개인 프로필 조회 API -------------------------

@router.get("/me", response_model=UserInfo)
def get_my_info(current_user: User = Depends(get_current_user)) -> Any:
    """
    [내 정보] 현재 로그인된 유저의 정보를 가져옵니다.
    """
    return current_user

# -------------- 닉네임 변경 API ---------------------
@router.patch("/profile")
def update_nickname(
    request: NicknameUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    current_user.nickname = request.nickname
    db.commit()
    db.refresh(current_user)
    
    return {"id": current_user.id, "nickname": current_user.nickname}

# ----------------- 프로필 이미지 변경 API ---------------------------
@router.post("/profile/image")
def update_profile_image(
    request: ProfileImageUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    [프로필 이미지 변경] 프론트엔드가 업로드 후 전달한 이미지 URL을 DB에 저장합니다.
    """
    # DB에 이미지 URL 업데이트
    current_user.image_url = request.imageUrl
    db.commit()
    db.refresh(current_user)
    
    return {
        "imageUrl": current_user.image_url
    }