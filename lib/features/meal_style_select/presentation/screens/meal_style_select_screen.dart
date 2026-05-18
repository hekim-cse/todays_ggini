import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot_speech.dart';
import '../../domain/meal_style.dart';
import '../widgets/meal_style_card.dart';

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
            // 말풍선
            const MascotSpeech(message: '이런 스타일은\n어떠세요?'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                itemCount: mockMealStyles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return MealStyleCard(
                    style: mockMealStyles[index],
                    isSelected: _selectedIndex == index,
                    onTap: () => setState(() => _selectedIndex = index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '위 식단은 예시 샘플 식단입니다.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedIndex == null
                          ? null
                          : () async {
                            // TODO(jungsoo): 임시 테스트용으로 추후에 제거
                            // 선택된 스타일에 해당하는 백엔드 style_id 매핑
                            final styleIds = [
                              'budget_first',
                              'nutrition_balance',
                              'diet_light',
                            ];
                            final styleId = styleIds[_selectedIndex!];
                            context.go(
                              '${AppRoutes.mealPlanLoading}?style_id=$styleId',
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.buttonGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    '이 스타일로 결정하기',
                    style: Theme.of(context).textTheme.labelLarge,
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
