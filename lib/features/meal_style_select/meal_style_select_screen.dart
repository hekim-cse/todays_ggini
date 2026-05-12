import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';

final List<Map<String, dynamic>> _mockStyles = [
  {
    'tag': '가성비 최우선',
    'meals': ['계란 볶음밥', '김치볶음밥', '제철 나물 비빔밥'],
    'stats': {'건강': 1, '가성비': 9, '맛': 4, '조리': 6},
    'desc': '가성비 자취생에게 추천!',
    'emoji': '🐹',
  },
  {
    'tag': '맛과 밸런스',
    'meals': ['닭갈비 정식', '차돌 된장찌개', '불고기 덮밥'],
    'stats': {'건강': 6, '가성비': 5, '맛': 9, '조리': 5},
    'desc': '골고루 고려한 식단!',
    'emoji': '🐹',
  },
  {
    'tag': '건강/바디프로필',
    'meals': ['닭가슴살 샐러드', '현미밥&생선구이', '곤약면 파스타'],
    'stats': {'건강': 9, '가성비': 2, '맛': 5, '조리': 8},
    'desc': '운동러에게 추천!',
    'emoji': '🐹',
  },
];

Color _getBarColor(int value) {
  if (value <= 3) return Colors.red;
  if (value <= 6) return Colors.green;
  return Colors.blue;
}

class MealStyleSelectScreen extends StatefulWidget {
  const MealStyleSelectScreen({super.key});

  @override
  State<MealStyleSelectScreen> createState() => _MealStyleSelectScreenState();
}

class _MealStyleSelectScreenState extends State<MealStyleSelectScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 로고
            const AppLogo(),

            // 제목
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                '이런 식단 스타일은 어떠세요?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // 스타일 카드 리스트
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                itemCount: _mockStyles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final style = _mockStyles[index];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                          ? AppColors.mypage
                          : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceDim,
                          width: 2.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 태그
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              style['tag'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 왼쪽: 샘플 식단
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '3일치 샘플 식단',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...(style['meals'] as List<String>)
                                        .map((meal) => Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 2),
                                              child: Row(
                                                children: [
                                                  const Text('🍽️',
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    meal,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                    const SizedBox(height: 4),
                                    Text(
                                      style['desc'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 오른쪽: 스탯 바
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (style['stats'] as Map<String, int>)
                                    .entries
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 40,
                                                child: Text(
                                                  e.key,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                width: e.value * 8.0,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: _getBarColor(e.value),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${e.value}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex == null
                      ? null
                      : () => context.go(AppRoutes.mealPlanLoading),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.surfaceDim,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    '이 스타일로 결정하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}