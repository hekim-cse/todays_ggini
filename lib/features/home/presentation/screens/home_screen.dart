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
          children: [Expanded(child: _buildBody(context, ref, state))],
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Center(
                //   child: Text(
                //     '오늘의 메뉴',
                //     style: Theme.of(context).textTheme.headlineLarge,
                //   ),
                // ),
                const SizedBox(height: 12),
                MealSlotTabs(
                  slotCount: plan.meals.length,
                  selectedSlot: state.selectedSlot,
                  onSlotSelected: (slot) {
                    ref.read(homeProvider.notifier).selectSlot(slot);
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuContent(context, state),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  state.selectedMenu == null
                      ? null
                      : () {
                        context.push(AppRoutes.mealDetailPath(DateTime.now()));
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.buttonGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                '재료 선택 및 메뉴 변경',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuContent(BuildContext context, HomeState state) {
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
        Center(
          child: Text(
            '<${menu.menuName}>',
            style: Theme.of(context).textTheme.headlineLarge,
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
