import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEEF4EE),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: const Column(
        children: [
          // 프로필 사진
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text('🐹', style: TextStyle(fontSize: 40)),
          ),
          SizedBox(height: 12),
          // 닉네임
          Text(
            '자취생123',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          // 페르소나
          Text(
            '가성비 자취생',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}