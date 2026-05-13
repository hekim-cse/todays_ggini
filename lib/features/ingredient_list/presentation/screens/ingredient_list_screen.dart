import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../shopping_selection/presentation/providers/shopping_selection_provider.dart';
import '../providers/ingredient_list_provider.dart';
import '../widgets/ingredient_row.dart';
import '../widgets/menu_summary_card.dart';

class IngredientListScreen extends ConsumerWidget {
  final String mealId;
  final DateTime? sourceDate;
  final int? sourceSlot;

  const IngredientListScreen({
    super.key,
    required this.mealId,
    this.sourceDate,
    this.sourceSlot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      mealId: mealId,
      date: sourceDate ?? DateTime.now(),
      slot: sourceSlot ?? 1,
    );
    final state = ref.watch(ingredientListProvider(args));
    final notifier = ref.read(ingredientListProvider(args).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBodyContent(context, ref, state, notifier)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
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
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
              ),
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
              '재료 목록',
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

  Widget _buildBodyContent(
    BuildContext context,
    WidgetRef ref,
    IngredientListState state,
    IngredientListNotifier notifier,
  ) {
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '재료 목록을 불러오지 못했습니다.\n${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.isLoading || state.menu == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final menu = state.menu!;

    final selection = ref.watch(shoppingSelectionProvider);
    final checkedSet =
        selection.selectionFor(sourceDate ?? DateTime.now(), sourceSlot ?? 1) ??
        <String>{};
    final totalPrice = menu.ingredients
        .where((i) => checkedSet.contains(i.ingredientId))
        .fold<int>(0, (sum, i) {
          final selectedMarket = selection.selectedMarketFor(i.ingredientId);
          return sum + i.effectivePrice(selectedMarket);
        });

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                MenuSummaryCard(
                  menu: menu,
                  sourceDate: sourceDate,
                  sourceSlot: sourceSlot,
                ),
                const SizedBox(height: 16),
                _buildSecondaryToggle(state, notifier),
                ...menu.ingredients.map(
                  (ing) => IngredientRow(
                    ingredient: ing,
                    isChecked: checkedSet.contains(ing.ingredientId),
                    selectedMarket: selection.selectedMarketFor(
                      ing.ingredientId,
                    ),
                    onToggle: () => notifier.toggleIngredient(ing.ingredientId),
                    onTapDetail: () {
                      context.push(
                        AppRoutes.ingredientDetailPath(ing.ingredientId),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildBottomSummary(
          checkedCount: checkedSet.length,
          totalPrice: totalPrice,
        ),
      ],
    );
  }

  Widget _buildSecondaryToggle(
    IngredientListState state,
    IngredientListNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            '부재료 제외',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Switch(
            value: state.excludeSecondary,
            onChanged: (_) => notifier.toggleExcludeSecondary(),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary({
    required int checkedCount,
    required int totalPrice,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '장볼 재료 ${checkedCount}개 · 부재료 0개 포함',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '합계 ₩${formatPrice(totalPrice)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
