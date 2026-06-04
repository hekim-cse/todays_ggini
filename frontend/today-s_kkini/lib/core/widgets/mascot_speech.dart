import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MascotSpeech extends StatelessWidget {
  final String message;
  final TextStyle? textStyle;
  final double height;

  const MascotSpeech({
    super.key,
    required this.message,
    this.textStyle,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/speech.png',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            left: 120,
            // left: MediaQuery.of(context).size.width * 0.23,
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: textStyle ?? const TextStyle(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
