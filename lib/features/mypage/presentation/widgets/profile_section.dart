import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileSection extends StatelessWidget {
  final String? name;
  final String? imagePath;
  final String persona;

  static int _userCount = 1; // 중복 방지용 카운터
  static final Set<int> _usedNumbers = {}; // 사용된 번호 추적

  static int _getUniqueNumber() {
    int number = _userCount;
    while (_usedNumbers.contains(number)) {
      number++;
    }
    _usedNumbers.add(number);
    _userCount = number + 1;
    return number;
  }

  const ProfileSection({
    super.key,
    this.name,
    this.imagePath,
    this.persona = '자취생',
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? '${persona}_${_getUniqueNumber()}';

    return Container(
      width: double.infinity,
      color: AppColors.mypage, // 변경 필요
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // 프로필 사진
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: imagePath != null
                ? ClipOval(
                    child: Image.asset(
                      imagePath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      'assets/images/pic.png', // 기본 로고 이미지
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          // 닉네임
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // 페르소나
          Text(
            persona,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textHint
            ),
          ),
        ],
      ),
    );
  }
}