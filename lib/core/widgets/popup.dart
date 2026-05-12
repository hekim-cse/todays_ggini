import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AppPopup extends StatelessWidget {
  final String content;
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  final Color? leftButtonColor;
  final Color? rightButtonColor;

  const AppPopup({
    super.key,
    required this.content,
    required this.leftButtonText,
    required this.rightButtonText,
    required this.onLeftTap,
    required this.onRightTap,
    this.leftButtonColor,
    this.rightButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
      ),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Column(
          children: [
            // 가로 구분선
            Divider(
              height: 1,
              color: AppColors.textSecondary,
            ),

            // 버튼들
            Row(
              children: [
                // 왼쪽 버튼
                Expanded(
                  child: TextButton(
                    onPressed: onLeftTap,
                    child: Text(
                      leftButtonText,
                      style: TextStyle(
                        color: leftButtonColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // 세로 구분선
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.textSecondary,
                ),

                // 오른쪽 버튼
                Expanded(
                  child: TextButton(
                    onPressed: onRightTap,
                    child: Text(
                      rightButtonText,
                      style: TextStyle(
                        color: rightButtonColor ?? AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// 팝업 띄우는 함수
void showAppPopup({
  required BuildContext context,
  required String content,
  required String leftButtonText,
  required String rightButtonText,
  required VoidCallback onLeftTap,
  required VoidCallback onRightTap,
  Color? leftButtonColor,
  Color? rightButtonColor,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AppPopup(
      content: content,
      leftButtonText: leftButtonText,
      rightButtonText: rightButtonText,
      onLeftTap: onLeftTap,
      onRightTap: onRightTap,
      leftButtonColor: leftButtonColor,
      rightButtonColor: rightButtonColor,
    ),
  );
}