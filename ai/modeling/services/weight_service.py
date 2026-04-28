# 목적별 기본 가중치를 저장한다.
# 모든 가중치의 합은 1이 되도록 설정한다.

GOAL_WEIGHTS = {
    "식비 절약": {
        "budget": 0.45,
        "nutrition": 0.20,
        "preference": 0.15,
        "difficulty": 0.10,
        "diversity": 0.10
    },
    "영양 균형": {
        "budget": 0.25,
        "nutrition": 0.40,
        "preference": 0.15,
        "difficulty": 0.10,
        "diversity": 0.10
    },
    "다이어트": {
        "budget": 0.20,
        "nutrition": 0.45,
        "preference": 0.15,
        "difficulty": 0.10,
        "diversity": 0.10
    },
    "고단백": {
        "budget": 0.20,
        "nutrition": 0.45,
        "preference": 0.15,
        "difficulty": 0.10,
        "diversity": 0.10
    },
    "간편식": {
        "budget": 0.25,
        "nutrition": 0.20,
        "preference": 0.15,
        "difficulty": 0.30,
        "diversity": 0.10
    },
    "맛 중심": {
        "budget": 0.20,
        "nutrition": 0.20,
        "preference": 0.40,
        "difficulty": 0.10,
        "diversity": 0.10
    }
}


def get_weights_by_goal(goal: str) -> dict:
    """
    사용자의 목적에 맞는 가중치를 반환한다.
    등록되지 않은 목적이 들어오면 기본값으로 '영양 균형'을 사용한다.
    """

    return GOAL_WEIGHTS.get(goal, GOAL_WEIGHTS["영양 균형"])