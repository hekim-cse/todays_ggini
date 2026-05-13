import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../providers/home_provider.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/meal_slot_tabs.dart';
import '../widgets/menu_video_player.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(context, ref, state)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HomeState state) {
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

    if (state.dailyPlan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final plan = state.dailyPlan!;

    return Column(
      children: [
        MealSlotTabs(
          slotCount: plan.meals.length,
          selectedSlot: state.selectedSlot,
          onSlotSelected: (slot) {
            ref.read(homeProvider.notifier).selectSlot(slot);
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildMenuSection(state),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: state.selectedMenu == null
                  ? null
                  : () {
                      context.go(AppRoutes.mealDetailPath(DateTime.now()));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceDim,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '재료 선택 및 메뉴 변경',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(HomeState state) {
    if (state.isLoadingMenu || state.selectedMenu == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final menu = state.selectedMenu!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 메뉴',
          style: TextStyle(
            fontSize: 26,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          menu.menuName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        MenuVideoPlayer(videoUrl: menu.videoUrl),
        const SizedBox(height: 20),
        ...List.generate(menu.ingredients.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IngredientCard(
              index: i + 1,
              ingredient: menu.ingredients[i],
            ),
          );
        }),
      ],
    );
  }
}