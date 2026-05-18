import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
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
    final state = ref.watch(ingredientListProvider(mealId));
    final notifier = ref.read(ingredientListProvider(mealId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBodyContent(context, state, notifier)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            color: AppColors.textPrimary,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.calendar);
              }
            },
          ),
          const Spacer(),
          Text(
            '재료 목록',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Spacer(),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:AppColors.error
            )
          ),
        ),
      );
    }

    if (state.isLoading || state.menu == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final menu = state.menu!;

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
                _buildSecondaryToggle(context, state, notifier),
                ...menu.ingredients.map(
                  (ing) => IngredientRow(
                    ingredient: ing,
                    isChecked: state.checkedIngredientIds.contains(
                      ing.ingredientId,
                    ),
                    onToggle: () => notifier.toggleIngredient(ing.ingredientId),
                    onTapDetail: () {
                      context.push(AppRoutes.ingredientDetailPath(ing.ingredientId));
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildBottomSummary(context, state),
      ],
    );
  }

  Widget _buildSecondaryToggle(
    BuildContext context,
    IngredientListState state,
    IngredientListNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '부재료 제외',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 5),
          Switch(
            value: state.excludeSecondary,
            onChanged: (_) => notifier.toggleExcludeSecondary(),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, IngredientListState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '장볼 재료 ${state.checkedCount}개 · 부재료 0개 포함',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '합계 ₩${formatPrice(state.totalPrice)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}