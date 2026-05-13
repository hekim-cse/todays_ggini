import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../domain/shopping_list.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_bottom_actions.dart';
import '../widgets/shopping_item_row.dart';
import '../widgets/shopping_list_summary.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shoppingListProvider);
    final notifier = ref.read(shoppingListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildBody(context, state, notifier),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ShoppingListState state,
    ShoppingListNotifier notifier,
  ) {
    if (state.error != null && state.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '장보기 목록을 불러오지 못했습니다.\n${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = state.data!;
    final flatRows = _flattenForDisplay(data);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          const Text(
            '장보기 목록',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ShoppingListSummary(data: data),
          const SizedBox(height: 16),
          Expanded(
            child: flatRows.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: flatRows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final (market, item) = flatRows[i];
                      return ShoppingItemRow(
                        item: item,
                        market: market,
                        onToggle: () => notifier.toggleItem(item.itemId),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          ShoppingBottomActions(
            hasCheckedItems: data.checkedItemsCount > 0,
            onDeleteChecked: () => _confirmDelete(context, notifier),
            onCheckoutByMarket: () => _notImplemented(context),
          ),
        ],
      ),
    );
  }

  List<(String, ShoppingItem)> _flattenForDisplay(ShoppingList data) {
    final out = <(String, ShoppingItem)>[];
    for (final g in data.marketGroups) {
      for (final item in g.items) {
        out.add((g.market, item));
      }
    }
    return out;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ShoppingListNotifier notifier,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text('선택한 항목을 목록에서 제거할까요?'),
        actionsPadding: EdgeInsets.zero,
        actions: [
          Column(
            children: [
              Divider(height: 1, color: AppColors.textSecondary),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('취소',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  Container(width: 1, height: 48, color: AppColors.textSecondary),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('제거',
                          style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    if (ok == true) {
      notifier.deleteCheckedItems();
    }
  }

  void _notImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('외부 마켓 결제 연동 예정')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '장보기 목록이 비어있어요',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}