import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class PersonaSelectScreen extends StatefulWidget {
  const PersonaSelectScreen({super.key});

  @override
  State<PersonaSelectScreen> createState() => _PersonaSelectScreenState();
}

class _PersonaSelectScreenState extends State<PersonaSelectScreen> {
  int? _selectedIndex;

  final List<Map<String, String>> _profiles = [
    {'title': '가성비 자취생', 'sub': '자취생 이미지', 'emoji': '🍳'},
    {'title': '우리가족 영양사', 'sub': '주부 이미지', 'emoji': '🥗'},
    {'title': '내 몸이 곧 재산', 'sub': '트레이너 이미지', 'emoji': '💪'},
    {'title': '퇴근 후 맥주한잔', 'sub': '직장인 이미지', 'emoji': '🍺'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // 로고
              Column(
                children: [
                  const Text('🐹', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text(
                    '오늘의 끼니',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // "나는..." 텍스트
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '나는...',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2x2 카드 그리드
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: List.generate(_profiles.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryDark
                                : const Color(0xFFCCCCCC),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 체크박스
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : const Color(0xFFCCCCCC),
                                ),
                              ),
                            ),

                            // 이모지 (나중에 이미지로 교체)
                            Text(
                              _profiles[index]['emoji']!,
                              style: const TextStyle(fontSize: 52),
                            ),

                            const SizedBox(height: 8),

                            // 제목
                            Text(
                              '[${_profiles[index]['title']}]',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            // 부제목
                            Text(
                              _profiles[index]['sub']!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // 시작하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex == null
                      ? null
                      : () => context.go(AppRoutes.auth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    '🪙 이 프로필로 시작하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 둘러보기 텍스트
              GestureDetector(
                onTap: () => context.go(AppRoutes.auth),
                child: const Text(
                  '회원가입 없이 둘러보기',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}