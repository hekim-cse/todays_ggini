import json


def fetch_candidate_menus_from_mock(
    rag_request: dict,
    file_path: str = "data/sample_menus.json"
) -> dict:
    """
    RAG가 아직 완성되지 않은 상태에서 사용할 mock RAG 함수이다.

    sample_menus.json을 읽은 뒤,
    실제 RAG 응답과 같은 형식으로 감싸서 반환한다.

    반환 형식:
    {
        "candidate_menus": [...]
    }
    """

    with open(file_path, "r", encoding="utf-8") as file:
        menus = json.load(file)

    candidate_count = rag_request["candidate_count"]

    # 현재는 sample 데이터에서 앞에서부터 candidate_count개만 가져온다.
    # 나중에 RAG가 완성되면 이 부분은 실제 검색 결과로 대체된다.
    candidate_menus = menus[:candidate_count]

    return {
        "candidate_menus": candidate_menus
    }


def fetch_candidate_menus_from_rag_api(rag_request: dict) -> dict:
    """
    실제 RAG API가 완성되면 이 함수에 연결한다.

    지금은 아직 구현하지 않고, 형식만 미리 잡아둔다.
    """

    raise NotImplementedError(
        "아직 실제 RAG API가 연결되지 않았습니다. "
        "현재는 fetch_candidate_menus_from_mock()을 사용하세요."
    )


def fetch_candidate_menus(
    rag_request: dict,
    use_mock: bool = True
) -> dict:
    """
    모델링 코드에서 호출할 공통 함수이다.

    use_mock=True:
    - sample_menus.json을 RAG 응답처럼 사용한다.

    use_mock=False:
    - 나중에 실제 RAG API를 호출하도록 전환한다.
    """

    if use_mock:
        return fetch_candidate_menus_from_mock(rag_request)

    return fetch_candidate_menus_from_rag_api(rag_request)