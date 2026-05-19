import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class MealDetailHeader extends StatefulWidget {
  final DateTime date;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;

  const MealDetailHeader({
    super.key,
    required this.date,
    required this.onPrevDay,
    required this.onNextDay,
  });

  @override
  State<MealDetailHeader> createState() => _MealDetailHeaderState();
}

class _MealDetailHeaderState extends State<MealDetailHeader> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null).then((_) {
      if (mounted) setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();

    final formatter = DateFormat('M월 d일 (E)', 'ko_KR');
    final label = formatter.format(widget.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textPrimary,
            iconSize: 32,
            onPressed: widget.onPrevDay,
          ),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textPrimary,
            iconSize: 32,
            onPressed: widget.onNextDay,
          ),
        ],
      ),
    );
  }
}
