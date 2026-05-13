import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../shopping_selection/presentation/providers/shopping_selection_provider.dart';
import '../providers/ingredient_detail_provider.dart';
import '../widgets/ingredient_header_card.dart';
import '../widgets/price_comparison_row.dart';

class IngredientDetailScreen extends ConsumerWidget {
  final String ingredientId;

  const IngredientDetailScreen({super.key, required this.ingredientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ingredientDetailProvider(ingredientId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context, ref, state)),
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
              '재료 상세',
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
    IngredientDetailState state,
  ) {
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '가격 정보를 불러오지 못했습니다.\n${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.isLoading || state.prices == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final prices = state.prices!;
    final selection = ref.watch(shoppingSelectionProvider);
    final selectedMarket = selection.selectedMarketFor(ingredientId);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          IngredientHeaderCard(prices: prices),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '마켓',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '가격',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 80),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 4),
          ...prices.sortedByPrice.map(
            (entry) => PriceComparisonRow(
              market: entry.key,
              price: entry.value,
              isUserSelected: selectedMarket == entry.key,
              onSelect: () {
                ref
                    .read(shoppingSelectionProvider.notifier)
                    .selectMarket(ingredientId, entry.key);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}