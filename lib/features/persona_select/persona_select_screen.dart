import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';

class PersonaSelectScreen extends StatefulWidget {
  const PersonaSelectScreen({super.key});

  @override
  State<PersonaSelectScreen> createState() => _PersonaSelectScreenState();
}

class _PersonaSelectScreenState extends State<PersonaSelectScreen> {
  int? _selectedIndex;

  final List<Map<String, String>> _profiles = [
    {'title': '가성비 자취생'},
    {'title': '우리가족 영양사'},
    {'title': '내 몸이 곧 재산'},
    {'title': '퇴근 후 맥주한잔'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // 로고
              const AppLogo(),

              const SizedBox(height: 24),

              // "나는..." 텍스트
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '   나는 ...',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.textPrimary,
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
                          color: const Color(0xFFE0E0E0),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                _profiles[index]['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
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
                      : () => context.go(
                          AppRoutes.onboarding,
                          extra: _profiles[_selectedIndex!]['title'],
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.surfaceDim,
                  ),
                  child: const Text(
                    '이 프로필로 시작하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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