import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class SettingItem extends StatefulWidget {
  final String emoji;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool showArrow;
  final bool showToggle;
  final Color? titleColor;

  const SettingItem({
    super.key,
    required this.emoji,
    required this.title,
    required this.value,
    required this.onTap,
    this.showArrow = true,
    this.showToggle = false,
    this.titleColor,
  });

  @override
  State<SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  bool _toggleValue = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.titleColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.showToggle)
              Switch(
                value: _toggleValue,
                onChanged: (v) => setState(() => _toggleValue = v),
                activeColor: AppColors.primaryDark,
              )
            else if (widget.value.isNotEmpty)
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            if (widget.showArrow) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}