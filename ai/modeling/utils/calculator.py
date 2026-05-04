def calculate_meal_budget(
    monthly_budget: int,
    meal_count_per_day: int,
    days_in_month: int
) -> int:
    """
    월 예산, 월 일수, 하루 식사 수를 기준으로 한 끼 예산을 계산한다.
    """

    return monthly_budget // days_in_month // meal_count_per_day