import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/calendar_preview.png',
      'label': '캘린더 사진',
    },
    {
      'image': 'assets/images/preview2.png',
      'label': '레시피 사진',
    },
    {
      'image': 'assets/images/shopping_preview.png',
      'label': '장보기 사진',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showLoginSheet();
    }
  }

  void _showLoginSheet() {
    final persona = GoRouterState.of(context).extra as String?;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LoginSheet(persona: persona),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _onTap,
        child: Column(
          children: [
            // 상단 진행바
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: List.generate(_pages.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _pages.length - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.surfaceDim,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // 사진 영역 (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '📸 ${_pages[index]['label']}\n(이미지로 교체 예정)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 하단 텍스트
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                _currentPage < _pages.length - 1
                    ? '화면을 터치해 주세요'
                    : '시작하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _currentPage < _pages.length - 1
                      ? AppColors.textHint
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 하단 로그인 시트
class _LoginSheet extends StatefulWidget {
  final String? persona;
  const _LoginSheet({this.persona});

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        color: AppColors.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // 소셜 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SocialButton(
                  label: '카카오',
                  color: const Color(0xFFFFE812),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.personaSelect);
                  },
                ),
                _SocialButton(
                  label: '네이버',
                  color: const Color(0xFF03C75A),
                  labelColor: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.personaSelect);
                  },
                ),
                _SocialButton(
                  label: '구글',
                  color: Colors.white,
                  border: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.personaSelect);
                  },
                ),
                _SocialButton(
                  label: '애플',
                  color: Colors.white,
                  border: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.personaSelect);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 구분선
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('또는', style: TextStyle(color: AppColors.textSecondary)),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 16),

            // 로그인 없이 시작하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: AppColors.background,
                      insetPadding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      contentPadding:
                          const EdgeInsets.fromLTRB(24, 32, 24, 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      content: const Text(
                        '로그인 없이 시작할 시,\n어플리케이션을 삭제하면\n저장된 정보가 모두 삭제됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                                // 로그인하기
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text(
                                      '로그인하기',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),

                                // 세로 구분선
                                Container(
                                  width: 1,
                                  height: 48,
                                  color: AppColors.textSecondary
                                ),

                                // 확인
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      Navigator.pop(context);
                                      context.go(AppRoutes.personaSelect);
                                    },
                                    child: Text(
                                      '확인',
                                      style: TextStyle(
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('로그인 없이 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 소셜 버튼
class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color labelColor;
  final VoidCallback onTap;
  final bool border;

  const _SocialButton({
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