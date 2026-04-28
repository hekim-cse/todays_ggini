import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

// 나중에 백엔드 데이터로 교체할 부분
final List<Map<String, dynamic>> _mockStyles = [
  {
    'tag': '가성비 최우선',
    'meals': ['계란 볶음밥', '스팸 김치 볶음밥', '제철 나물 비빔밥'],
    'stats': {'건강': 1, '가성비': 9, '맛': 4, '조리': 6},
    'desc': '가성비 자취생에게 추천!',
    'emoji': '🐹',
  },
  {
    'tag': '맛과 밸런스',
    'meals': ['닭갈비 정식', '소고기 된장찌개', '불고기 비빔밥'],
    'stats': {'건강': 6, '가성비': 5, '맛': 9, '조리': 5},
    'desc': '가성비 자취생에게 추천!',
    'emoji': '🐹',
  },
  {
    'tag': '건강/바디프로필',
    'meals': ['닭가슴살 샐러드', '현미밥 & 생선구이', '두부 곤약면 파스타'],
    'stats': {'건강': 10, '가성비': 2, '맛과 밸런스': 5, '쉬운 조리': 8},
    'desc': '제철 추천!',
    'emoji': '🐹',
  },
];

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 로고 + 햄스터
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 끼니픽 로고
                  const Text(
                    '오늘의 끼니',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  // 햄스터 이모지
                  const Text('🐹', style: TextStyle(fontSize: 40)),
                ],
              ),
            ),

            // 제목
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                '이런 식단 스타일은\n어떠세요?',
                style: TextStyle(
                  fontSize: 28,
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
                        color: const Color(0xFFEEF4EE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryDark
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽: 태그 + 이모지
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '[${style['tag']}]',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                style['emoji'],
                                style: const TextStyle(fontSize: 48),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          // 가운데: 샘플 식단
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '3일치 샘플 식단',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
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
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  meal,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                const SizedBox(height: 4),
                                Text(
                                  style['desc'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 오른쪽: 스탯 바
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: (style['stats'] as Map<String, int>)
                                .entries
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          Text(
                                            '[${e.key}]',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            width: e.value * 5.0,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryDark,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${e.value}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
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
                    backgroundColor: AppColors.primaryDark,
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    '🪙 이 스타일로 결정하기',
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