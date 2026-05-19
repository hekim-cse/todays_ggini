

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AppPopup extends StatelessWidget {
  final String? content;
  final Widget? contentWidget;
  final String? title;
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  final Color? leftButtonColor;
  final Color? rightButtonColor;

  const AppPopup({
    super.key,
    this.content,
    this.contentWidget,
    this.title,
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
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: title != null
          ? Text(
              title!,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            )
          : null,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: contentWidget ??
            Text(
              content ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
      ),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Column(
          children: [
            Divider(height: 1, color: AppColors.border),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onLeftTap,
                    child: Text(
                      leftButtonText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: leftButtonColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 48, color: AppColors.border),
                Expanded(
                  child: TextButton(
                    onPressed: onRightTap,
                    child: Text(
                      rightButtonText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rightButtonColor ?? AppColors.border,
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

// 기존 함수 (그대로 동작)
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
    builder:
        (dialogContext) => AppPopup(
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

// 위젯 content용 함수 (새로 추가)
void showAppPopupWidget({
  required BuildContext context,
  String? title,
  required Widget contentWidget,
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
      title: title,
      contentWidget: contentWidget,
      leftButtonText: leftButtonText,
      rightButtonText: rightButtonText,
      onLeftTap: onLeftTap,
      onRightTap: onRightTap,
      leftButtonColor: leftButtonColor,
      rightButtonColor: rightButtonColor,
    ),
  );
}
