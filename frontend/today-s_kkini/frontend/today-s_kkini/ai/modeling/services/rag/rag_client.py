import os
import requests


RAG_API_URL = os.getenv(
    "RAG_API_URL",
    "https://api.kkini.cloud/api/v1/meal-candidates",
)


def request_candidate_menus_from_rag(rag_request: dict) -> dict:
    """
    RAG 서버에 후보 메뉴를 요청한다.
    """

    response = requests.post(
        RAG_API_URL,
        json=rag_request,
        timeout=15,
    )

    if response.status_code >= 400:
        raise RuntimeError(
            "RAG API 요청 실패\n"
            f"status_code: {response.status_code}\n"
            f"url: {RAG_API_URL}\n"
            f"request_body: {rag_request}\n"
            f"response_text: {response.text}"
        )

    return response.json()