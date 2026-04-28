import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_section.dart';
import '../widgets/section_title.dart';
import '../widgets/setting_item.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            const ProfileSection(),

            const SizedBox(height: 24),

            // 내 설정
            const SectionTitle(title: '내 설정'),
            SettingItem(
              emoji: '🎭',
              title: '페르소나',
              value: '가성비 자취생',
              onTap: () {},
            ),
            SettingItem(
              emoji: '👨‍🍳',
              title: '요리실력',
              value: '3 / 10',
              onTap: () {},
            ),
            SettingItem(
              emoji: '💰',
              title: '한달 식비 예산',
              value: '300,000원',
              onTap: () {},
            ),
            SettingItem(
              emoji: '🍽️',
              title: '식단 스타일',
              value: '가성비 최우선',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // 앱 설정
            const SectionTitle(title: '앱 설정'),
            SettingItem(
              emoji: '🔔',
              title: '알림 설정',
              value: '',
              onTap: () {},
              showToggle: true,
              showArrow: false,
            ),

            const SizedBox(height: 24),

            // 계정
            const SectionTitle(title: '계정'),
            SettingItem(
              emoji: '🚪',
              title: '로그아웃',
              value: '',
              onTap: () => _showLogoutDialog(context),
              showArrow: false,
            ),
            SettingItem(
              emoji: '⚠️',
              title: '회원탈퇴',
              value: '',
              titleColor: Colors.red,
              onTap: () => _showDeleteAccountDialog(context),
              showArrow: false,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 로그아웃 로직
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠어요?\n모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 회원탈퇴 로직
            },
            child: const Text(
              '탈퇴하기',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}