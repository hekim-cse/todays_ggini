import json


def build_default_recipe(menu: dict) -> dict:
    """
    mock RAG 환경에서 recipe 필드가 없을 때 사용할 기본 레시피를 생성한다.

    실제 RAG가 완성되면 RAG가 직접 recipe를 내려주므로,
    이 함수는 mock 테스트용 보조 역할만 한다.
    """

    menu_name = menu.get("name", "메뉴")
    ingredients = menu.get("ingredients", [])
    cooking_time = menu.get("cooking_time", 0)

    return {
        "serving_size": 1,
        "cooking_time": cooking_time,
        "steps": [
            f"{menu_name}에 필요한 재료를 준비한다.",
            "재료를 먹기 좋은 크기로 손질한다.",
            "준비한 재료를 조리 순서에 맞게 조리한다.",
            "그릇에 담아 완성한다."
        ],
        "required_ingredients": ingredients,
        "optional_ingredients": [],
        "substitution_ingredients": {}
    }


def normalize_menu_for_rag_response(menu: dict) -> dict:
    """
    sample_menus.json의 메뉴 데이터를 RAG 응답 형식에 맞게 정리한다.

    recipe가 없으면 mock용 기본 recipe를 추가한다.
    similar_menu_ids가 없으면 빈 리스트를 넣는다.
    """

    normalized_menu = dict(menu)

    if "recipe" not in normalized_menu:
        normalized_menu["recipe"] = build_default_recipe(normalized_menu)

    if "similar_menu_ids" not in normalized_menu:
        normalized_menu["similar_menu_ids"] = []

    return normalized_menu


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

    candidate_menus = [
        normalize_menu_for_rag_response(menu)
        for menu in menus[:candidate_count]
    ]

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