import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';  // ← 추가
import '../../domain/monthly_meal_plan.dart';
import 'day_cell.dart';

class MonthGrid extends StatelessWidget {
  final int year;
  final int month;
  final MonthlyMealPlan plan;
  final void Function(DateTime date) onDayTap;

  const MonthGrid({
    super.key,
    required this.year,
    required this.month,
    required this.plan,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayMap = <int, DayEntry>{for (final d in plan.days) d.date.day: d};

    final firstDay = DateTime(year, month, 1);
    final firstWeekday = firstDay.weekday;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final leadingEmpty = firstWeekday - 1;
    final totalCells = ((leadingEmpty + daysInMonth + 6) ~/ 7) * 7;
    final trailingEmpty = totalCells - leadingEmpty - daysInMonth;

    final cells = <DayCell>[
      for (var i = 0; i < leadingEmpty; i++) const DayCell(day: null),
      for (var d = 1; d <= daysInMonth; d++)
        // DayCell(
        //   day: dayMap[d],
        //   onTap: dayMap[d]?.hasMealPlan == true
        //       ? () => onDayTap(DateTime(year, month, d))
        //       : null,
        // ),
        DayCell(
          day: dayMap[d],
          isToday: year == 2026 && month == 5 && d == 15,  // ← 5/15 고정
          onTap: dayMap[d]?.hasMealPlan == true
              ? () => onDayTap(DateTime(year, month, d))
              : null,
        ),
      for (var i = 0; i < trailingEmpty; i++) const DayCell(day: null),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _weekdayHeader(context),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.border, width: 1), 
              ),
            ),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.55,
              children: cells,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekdayHeader(BuildContext context)  {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1), 
                  ),
                ),
                child: Center(
                  child: Text(
                    l,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}