import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../home/domain/menu_detail.dart';

class MenuSummaryCard extends StatelessWidget {
  final MenuDetail menu;
  final DateTime? sourceDate;
  final int? sourceSlot;

  const MenuSummaryCard({
    super.key,
    required this.menu,
    this.sourceDate,
    this.sourceSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(6),
            ),
            child: menu.imageUrl == null
                ? const Center(
                    child: Text(
                      '이미지',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(menu.imageUrl!, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.menuName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatPrice(menu.calories)} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (sourceDate != null || sourceSlot != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatSource(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSource() {
    final parts = <String>[];
    if (sourceDate != null) {
      parts.add('${sourceDate!.month}월 ${sourceDate!.day}일');
    }
    if (sourceSlot != null) {
      parts.add('식단$sourceSlot');
    }
    return parts.join(' ');
  }
}