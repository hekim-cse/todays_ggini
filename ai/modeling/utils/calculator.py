import calendar


def get_days_in_month(year: int, month: int) -> int:
    """
    입력받은 연도와 월에 해당하는 실제 일수를 반환한다.

    예:
    2026년 1월 -> 31일
    2026년 2월 -> 28일
    2024년 2월 -> 29일
    """

    return calendar.monthrange(year, month)[1]


def calculate_meal_budget(
    monthly_budget: int,
    meal_count_per_day: int,
    year: int,
    month: int
) -> int:
    """
    월 예산과 하루 식사 수를 기준으로 한 끼 예산을 계산한다.

    기존처럼 30일로 고정하지 않고,
    실제 해당 월의 일수를 기준으로 계산한다.

    예:
    2026년 1월
    월 예산 300,000원
    하루 2끼
    1월은 31일

    300000 / 31 / 2 = 약 4838원
    """

    days_in_month = get_days_in_month(year, month)

    meal_budget = monthly_budget // days_in_month // meal_count_per_day

    return meal_budget