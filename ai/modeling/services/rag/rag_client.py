import json
from pathlib import Path


def request_candidate_menus_from_rag(rag_request: dict) -> dict:
    """
    Modeling에서 만든 RAG 요청을 받아 후보 메뉴 응답을 반환한다.

    현재는 실제 RAG 서버 연동 전이므로,
    data/sample_rag_response_200.json 파일을 테스트용 RAG 응답으로 사용한다.
    """

    # 현재 파일 위치:
    # services/rag/rag_client.py
    #
    # 목표 데이터 위치:
    # data/sample_rag_response_200.json
    base_dir = Path(__file__).resolve().parents[2]
    sample_rag_response_path = base_dir / "data" / "sample_rag_response_200.json"

    with open(sample_rag_response_path, "r", encoding="utf-8") as file:
        rag_response = json.load(file)

    # 실제 RAG 연동 전까지는 candidate_count만 반영해서 잘라준다.
    candidate_count = rag_request.get("candidate_count")

    if candidate_count:
        rag_response["candidate_menus"] = rag_response.get("candidate_menus", [])[:candidate_count]

    return rag_response