import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../providers/meal_detail_provider.dart';
import '../widgets/meal_detail_header.dart';
import '../widgets/meal_detail_summary.dart';
import '../widgets/slot_card.dart';

class MealDetailScreen extends ConsumerWidget {
  final DateTime date;

  const MealDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealDetailProvider(date));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            MealDetailHeader(
              date: date,
              onPrevDay: () => _goToDate(
                context,
                date.subtract(const Duration(days: 1)),
              ),
              onNextDay: () => _goToDate(
                context,
                date.add(const Duration(days: 1)),
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  void _goToDate(BuildContext context, DateTime newDate) {
    context.go(AppRoutes.mealDetailPath(newDate));
  }

  Widget _buildBody(BuildContext context, MealDetailState state) {
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '식단을 불러오지 못했습니다.\n${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.isLoading || state.plan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasMealPlan) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '이 날은 식단이 없습니다.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    final plan = state.plan!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          MealDetailSummary(
            totalPrice: plan.pricePerDay,
            totalCalories: plan.caloriesPerDay,
          ),
          const SizedBox(height: 16),
          ...plan.meals.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SlotCard(
                meal: m,
                onSelectIngredients: () {
                  final dateStr =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  context.push(
                    '${AppRoutes.ingredientListPath(m.mealId)}?date=$dateStr&slot=${m.slot}',
                  );
                },
                onChangeMenu: () {
                  context.push(AppRoutes.menuChangePath(
                    mealId: m.mealId,
                    date: date,
                    slot: m.slot,
                  ));
                },
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                context.go(AppRoutes.shoppingList);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '이 날 장보기 목록 추가',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}