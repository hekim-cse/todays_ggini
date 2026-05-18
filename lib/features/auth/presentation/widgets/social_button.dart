import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color labelColor;
  final VoidCallback onTap;
  final bool border;
  final TextStyle? labelStyle;

  const SocialButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.labelColor = Colors.black,
    this.border = false,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border ? Border.all(color: AppColors.buttonGray) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: labelStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}