import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color labelColor;
  final VoidCallback onTap;
  final bool border;

  const SocialButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.labelColor = Colors.black,
    this.border = false,
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
          border: border ? Border.all(color: Colors.grey.shade300) : null,
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
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}