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

  void _onTap(String goal) {
    final newList = List<String>.from(widget.selectedGoals);
    if (newList.contains(goal)) {
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
  }


  Widget _buildRow(BuildContext context, List<String> items) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final goal = entry.value;
        final isSelected = widget.selectedGoals.contains(goal);
        return Expanded(
          child: GestureDetector(
            onTap: () => _onTap(goal),
            child: Container(
              margin: EdgeInsets.only(right: index < items.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.buttonGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      goal,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '[목적]',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final textStyle = Theme.of(context).textTheme.bodyMedium;
            double totalWidth = 0;
            for (final goal in _goals) {
              final tp = TextPainter(
                text: TextSpan(text: goal, style: textStyle),
                textDirection: TextDirection.ltr,
              )..layout();
              totalWidth += tp.width + 32;
            }
            totalWidth += 8 * (_goals.length - 1);

            if (totalWidth <= constraints.maxWidth) {
              return _buildRow(context, _goals);
            } else {
              final half = (_goals.length / 2).ceil();
              return Column(
                children: [
                  _buildRow(context, _goals.sublist(0, half)),
                  const SizedBox(height: 8),
                  _buildRow(context, _goals.sublist(half)),
                ],
              );
            }
          },
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}