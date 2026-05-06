import json
from pathlib import Path


def load_sample_menus() -> list[dict]:
    """
    sample_menus.json 파일에서 샘플 메뉴 데이터를 읽어온다.
    """

    file_path = Path("data/sample_menus.json")

    with open(file_path, "r", encoding="utf-8") as file:
        menus = json.load(file)

    return menus