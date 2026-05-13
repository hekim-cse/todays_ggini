import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/daily_meal_plan.dart';
import '../../../meal_detail/presentation/providers/meal_detail_provider.dart';
import '../../domain/menu_alternatives.dart';
import '../providers/menu_change_provider.dart';
import '../widgets/alternative_meal_row.dart';
import '../widgets/current_meal_card.dart';

class MenuChangeScreen extends ConsumerWidget {
  final String mealId;
  final DateTime date;
  final int slot;

  const MenuChangeScreen({
    super.key,
    required this.mealId,
    required this.date,
    required this.slot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (mealId: mealId, date: date, slot: slot);
    final state = ref.watch(menuChangeProvider(args));
    final notifier = ref.read(menuChangeProvider(args).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context, ref, state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.calendar);
                }
              },
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Text(
              '메뉴 변경',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MenuChangeState state,
    MenuChangeNotifier notifier,
  ) {
    if (state.error != null && state.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '대안 식단을 불러오지 못했습니다.\n${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final mealDetailState = ref.watch(mealDetailProvider(date));
    final currentPlan = mealDetailState.plan;

    if (state.data == null || currentPlan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final matching = currentPlan.meals.where((m) => m.slot == slot);
    if (matching.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '해당 슬롯 데이터를 찾을 수 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    final currentSlotMeal = matching.first;

    final displayCurrentMeal = CurrentMeal(
      mealId: currentSlotMeal.mealId,
      menuName: currentSlotMeal.menuName,
      calories: currentSlotMeal.calories,
      price: currentSlotMeal.price,
      imageUrl: currentSlotMeal.imageUrl,
      date: date,
      slot: slot,
    );

    final visibleAlternatives = state.data!.alternatives
        .where((a) => a.mealId != currentSlotMeal.mealId)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(text: '현재 메뉴'),
          const SizedBox(height: 8),
          CurrentMealCard(meal: displayCurrentMeal),
          const SizedBox(height: 20),
          const _SectionLabel(text: '추천 대안 식단'),
          const SizedBox(height: 8),
          for (final alt in visibleAlternatives) ...[
            AlternativeMealRow(
              meal: alt,
              isDisabled: state.isChanging,
              onChange: () => _onChange(context, ref, notifier, currentPlan, alt),
            ),
            const SizedBox(height: 8),
          ],
          if (state.isChanging) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Future<void> _onChange(
    BuildContext context,
    WidgetRef ref,
    MenuChangeNotifier notifier,
    DailyMealPlan currentPlan,
    AlternativeMeal chosen,
  ) async {
    final newPlan = await notifier.applyChange(
      currentPlan: currentPlan,
      chosenAlternative: chosen,
    );
    if (!context.mounted) return;

    if (newPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메뉴 변경에 실패했습니다.')),
      );
      return;
    }

    ref.read(mealDetailProvider(date).notifier).replaceWith(newPlan);

    if (context.canPop()) {
      context.pop();
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}