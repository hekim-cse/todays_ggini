import 'package:flutter/material.dart';

/// 끼니픽 색상 팔레트. 피그마 모킹업에서 추출.
class AppColors {
  const AppColors._();

  // Brand greens (sage / olive)
  static const Color primary = Color(0xFF3EB440); // main 녹색
  static const Color mypage = Color(0xFFE1F3D8); // 마이페이지용 - 변경 필요
  static const Color primaryLight = Color(0xFFFAFAF8); // 팝업창, 로그인창

  // Background / surfaces
  static const Color background = Color(0xFFFFFBF0); // 전체적인 배경 - 아이보리
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFD9D9D9); // 회색 배경용

  // Text (warm dark brown 계열)
  static const Color textPrimary = Color(0xFF4A3F35); // 기본 글씨 색
  static const Color textSecondary = Color(0xFFCFC2B3); // 팝업창 내에서 구분선
  static const Color textHint = Color(0xFFA7A198); // 메인 외 글씨
  static const Color textGray = Color(0xFF515151); // 글씨 회색

  // Accent (K coin yellow)
  static const Color accent = Color(0xFFF4C842);

  // Semantic
  static const Color error = Color(0xFFD64545);
  static const Color border = Color(0xFFD9CFBE);
}
