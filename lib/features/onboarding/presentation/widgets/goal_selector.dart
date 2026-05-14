import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GoalSelector extends StatefulWidget {
  final List<String> selectedGoals;
  final ValueChanged<List<String>> onChanged;

  const GoalSelector({
    super.key,
    required this.selectedGoals,
    required this.onChanged,
  });

  @override
  State<GoalSelector> createState() => _GoalSelectorState();
}

class _GoalSelectorState extends State<GoalSelector> {
  final List<String> _goals = ['식비 절약', '영양 균형', '다이어트', '고단백', '간편식', '맛 중심'];
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '[목적]',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _goals.map((goal) {
            final isSelected = widget.selectedGoals.contains(goal);
            return GestureDetector(
              onTap: () {
                final newList = List<String>.from(widget.selectedGoals);
                if (isSelected) {
                  newList.remove(goal);
                  setState(() => _error = null);
                } else if (newList.length < 3) {
                  newList.add(goal);
                  setState(() => _error = null);
                } else {
                  setState(() => _error = '최대 3개까지 선택이 가능합니다.');
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _error = null);
                  });
                  return;
                }
                widget.onChanged(newList);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}