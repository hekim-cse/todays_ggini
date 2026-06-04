import httpx
import logging
from typing import Optional, List
from openai import AsyncOpenAI
from app.core.config import settings
from app.core.redis import redis_client

logger = logging.getLogger(__name__)

# OpenAI 비동기 클라이언트 선언
openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)

# 이미지 매핑용 고유 접두사와 캐시 만료 기간(30일) 설정
REDIS_CACHE_PREFIX = "food_image:"
CACHE_TTL_DAYS = 30

async def _get_optimized_keyword(menu_name: str) -> str:
    """
    [1단계] LLM 기반 검색 쿼리 전처리 최적화
    한국어 메뉴명을 Pixabay에서 검색이 잘되는 영문 핵심 키워드로 변환합니다.
    """
    try:
        response = await openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system", 
                    "content": (
                        "You are a professional image search query optimizer. "
                        "Convert the given Korean food/meal name into 1 or 2 high-quality, generic English keywords suitable for stock photo search. "
                        "Output ONLY the keywords, nothing else. "
                        "Example: '다이어트용 저염 닭가슴살 샐러드' -> 'Chicken Salad'"
                    )
                },
                {"role": "user", "content": menu_name}
            ],
            temperature=0.3,  # 값이 낮을수록 AI가 헛소리를 안 하고 일관된 답변을 냅니다.
            max_tokens=20     # 토큰 제한을 걸어 비용을 아낍니다.
        )
        
        # AI가 뱉은 결과물에서 앞뒤 공백을 제거
        keyword = response.choices[0].message.content.strip()
        logger.info(f"🔮 [Query Optimization] {menu_name} -> {keyword}")
        return keyword

    except Exception as e:
        logger.error(f"LLM 쿼리 최적화 실패 (기본 메뉴명 Fallback 사용): {e}")
        return menu_name  # 에러 발생 시 시스템이 멈추지 않게 원래 이름을 그대로 반환
    
import asyncio

async def _search_pixabay_images(keyword: str, category: str = "food") -> list:
    """
    [2단계] Pixabay API 호출 (후보군 3개 확보)
    정제된 영문 키워드를 가지고 스톡 이미지 URL 최대 3개를 긁어옵니다.
    """
    url = "https://pixabay.com/api/"
    params = {
        "key": settings.PIXABAY_API_KEY,
        "q": keyword,               # 1단계에서 얻은 영문 키워드
        "image_type": "photo",
        "category": category,        # 정확도를 위해 food 카테고리로 제한
        "per_page": 3,               # VLM 검증용으로 상위 3개만 수집
        "safesearch": "true"
    }
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, params=params)
            data = response.json()
            
            # 검색 결과(hits)에서 각 이미지의 웹용 URL(webformatURL)만 뽑아 리스트로 만듭니다.
            if data.get("hits"):
                image_urls = [hit["webformatURL"] for hit in data["hits"]]
                return image_urls
                
        except Exception as e:
            print(f"Pixabay API 연동 실패: {e}")
            
    return [] # 결과가 없거나 에러 시 빈 리스트 반환

async def _verify_images_with_vlm(menu_name: str, image_urls: list) -> str:
    """
    [3단계] VLM(Vision-Language Model) 기반 이미지 검증 필터링
    비전 AI가 이미지 URL들을 실제로 분석하여 메뉴명과 가장 매칭되는 이미지의 URL을 반환합니다.
    """
    if not image_urls:
        return None

    try:
        # 비전 모델에게 사진과 텍스트를 함께 전달하기 위한 멀티모달 프롬프트 조립
        content = [
            {
                "type": "text", 
                "text": (
                    f"You are a food image auditor. The user's actual Korean meal is '{menu_name}'. "
                    "Review the provided image URLs and choose the one that best and most accurately depicts this specific Korean food. "
                    "If all images are irrelevant or look completely different from the Korean dish, answer 'NONE'. "
                    "Otherwise, reply ONLY with the exact index number (e.g., 0 or 1 or 2) of the best image. Do not write anything else."
                )
            }
        ]
        
        # 반복문을 돌며 AI에게 각각의 이미지 주소를 '눈(image_url)'으로 넣어줍니다.
        for idx, url in enumerate(image_urls):
            content.append({"type": "text", "text": f"Image Index {idx}:"})
            content.append({"type": "image_url", "image_url": {"url": url}})

        # gpt-4o-mini는 텍스트뿐만 아니라 이미지도 볼 줄 아는 멀티모달 모델입니다.
        response = await openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": content}],
            temperature=0.1,  # 엄격한 판정을 위해 온도를 대폭 낮춤
            max_tokens=5
        )
        
        result = response.choices[0].message.content.strip()
        # 만약 AI가 'NONE'을 외치거나 숫자가 아닌 답을 주면 부적합 처리
        if result == "NONE" or not result.isdigit():
            return None
            
        chosen_idx = int(result)
        if 0 <= chosen_idx < len(image_urls):
            return image_urls[chosen_idx]  # 최종 합격한 이미지 URL 딱 1개 반환
            
    except Exception as e:
        print(f"VLM 검증 단계 에러: {e}")
        
    return None


async def get_food_image_url(menu_name: str, category: str = "food") -> str:
    """
    [Main Pipeline] AI 이미지 파이프라인 + 기존 Pixabay Fallback + Redis 캐싱 통합형 함수
    """
    cache_key = f"{REDIS_CACHE_PREFIX}{menu_name}_{category}"
    
    # 1. Redis 분산 캐시 확인 (Cache Hit)
    try:
        cached_url = await redis_client.get(cache_key)
        if cached_url:
            print(f"[Cache Hit] Redis에서 이미 캐싱된 이미지를 즉시 반환합니다: {menu_name}")
            return cached_url
    except Exception as e:
        print(f"Redis 조회 중 일시적 에러 발생: {e}")

    print(f"[Cache Miss] Redis에 데이터가 없어 AI 고도화 파이프라인을 가동합니다")

    # AI 기반 전처리 및 후보군 수집
    optimized_keyword = await _get_optimized_keyword(menu_name)
    candidate_urls = await _search_pixabay_images(optimized_keyword, category)
    
    # VLM 검증 단계 가동
    final_img_url = await _verify_images_with_vlm(menu_name, candidate_urls)

    # 2. [Fallback 레이어] 
    # VLM이 탈락시켰거나 에러가 났을 경우, 기존 방식대로 Pixabay가 찾아왔던 첫 번째 원본 이미지[0]를 그대로 차용합니다.
    if not final_img_url:
        if candidate_urls:
            print(f"[Fallback] VLM 판정 실패로 인해 기존 방식대로 Pixabay의 첫 번째 검색 결과를 매핑합니다.")
            final_img_url = candidate_urls[0]
        else:
            print(f"Pixabay 검색 결과조차 아예 없어 이미지 매핑이 불가능합니다.")
            return None  # 검색 자체가 완전 실패한 경우

    # 3. 원본을 썼든, AI 검증을 통과했든 최종 확정된 URL을 Redis에 캐싱하여 다음 요청부턴 돈이 안 들게 방어합니다.
    try:
        ttl_seconds = CACHE_TTL_DAYS * 24 * 60 * 60
        await redis_client.setex(name=cache_key, time=ttl_seconds, value=final_img_url)
        print(f"[Cache Write] {menu_name}의 결과 이미지 주소를 Redis에 30일간 캐싱 완료!")
    except Exception as e:
        print(f"Redis 캐시 쓰기 실패: {e}")

    return final_img_url