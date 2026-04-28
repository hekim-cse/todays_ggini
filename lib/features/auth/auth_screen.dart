import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상단 초록 배경 + 로고 + 캘린더 프리뷰
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: AppColors.primaryDark,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 로고
                  const Positioned(
                    top: 60,
                    child: Column(
                      children: [
                        Text('🐹', style: TextStyle(fontSize: 48)),
                        Text(
                          '오늘의 끼니',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 캘린더 프리뷰
                  Positioned(
                    bottom: 0,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 430,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '📅 캘린더 프리뷰\n(이미지로 교체 예정)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 로그인
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // 안내 텍스트
                  const Text(
                    '나만의 맞춤 식단 관리 시작하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 소셜 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        color: const Color(0xFFFFE812),
                        onTap: () => context.go(AppRoutes.onboarding),
                        child: const Text('💬',
                            style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      _SocialButton(
                        color: const Color(0xFF03C75A),
                        onTap: () => context.go(AppRoutes.onboarding),
                        child: const Text('N',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                      const SizedBox(width: 12),
                      _SocialButton(
                        color: Colors.white,
                        border: true,
                        onTap: () => context.go(AppRoutes.onboarding),
                        child: const Text('G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            )),
                      ),
                      const SizedBox(width: 12),
                      _SocialButton(
                        color: Colors.white,
                        border: true,
                        onTap: () => context.go(AppRoutes.onboarding),
                        child: const Text('🍎',
                            style: TextStyle(fontSize: 22)),
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
                        child: Text('또는',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 이메일
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration('ID'),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 8),

                  // 비밀번호
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration('비밀번호').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 비밀번호 찾기
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        '비밀번호를 잊으셨나요?',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.onboarding),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 회원가입 이동
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '아직 계정이 없으신가요?',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.onboarding),
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 둘러보기
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.onboarding),
                    child: const Text(
                      '회원가입 없이 둘러보기',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDark),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback onTap;
  final bool border;

  const _SocialButton({
    required this.color,
    required this.child,
    required this.onTap,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
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
        child: Center(child: child),
      ),
    );
  }
}