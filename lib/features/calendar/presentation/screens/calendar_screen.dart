import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../providers/calendar_provider.dart';
import '../widgets/month_grid.dart';
import '../widgets/month_header.dart';
import '../widgets/summary_card.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: _buildBody(context, state, notifier),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1), // ← 캘린더는 1
    );
  }

  Widget _buildBody(
    BuildContext context,
    CalendarState state,
    CalendarNotifier notifier,
  ) {
    if (state.error != null && state.currentPlan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '캘린더를 불러오지 못했습니다.\n${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.currentPlan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final plan = state.currentPlan!;

    return SingleChildScrollView(  // ← bottomNavigationBar 제거
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '식단 캘린더',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF515151),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD9D9D9), width: 3.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SummaryCard(
                month: state.currentMonth,
                totalPrice: plan.totalPricePerMonth,
                averageCalories: plan.averageCaloriesPerMonth,
              ),
            ),
            const SizedBox(height: 8),
            MonthHeader(
              year: state.currentYear,
              month: state.currentMonth,
              onPrevMonth: notifier.goToPrevMonth,
              onNextMonth: notifier.goToNextMonth,
            ),
            MonthGrid(
              year: state.currentYear,
              month: state.currentMonth,
              plan: plan,
              onDayTap: (date) {
                context.push(AppRoutes.mealDetailPath(date));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}