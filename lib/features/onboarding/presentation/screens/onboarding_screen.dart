import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/labeled_slider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final submitState = ref.watch(submitOnboardingProvider);
    final isSubmitting = submitState?.isLoading ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 햄스터
              const Center(
                child: Text('🐹', style: TextStyle(fontSize: 48)),
              ),

              const SizedBox(height: 16),

              // 제목
              Center(
                child: Text(
                  '나에게 딱 맞게 설정하기',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 32, // 숫자 키울수록 글씨 커짐
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 요리실력 슬라이더
              _SliderCard(
                title: '[내 요리실력]',
                leftLabel: '초보\n(라면)',
                rightLabel: '고수\n(일류쉐프)',
                leftEmoji: '🍜',
                rightEmoji: '👨‍🍳',
                value: draft.cookingSkill,
                onChanged: notifier.setCookingSkill,
              ),

              const SizedBox(height: 24),

              // 식재료 선호도 제목
              const Text(
                '[식재료 선호도]',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // 채소 ↔ 육류 + 냉동 ↔ 신선 가로 배치
              Row(
                children: [
                  Expanded(
                    child: _SliderCard(
                      title: '[채소 ↔ 육류]',
                      leftLabel: '',
                      rightLabel: '',
                      leftEmoji: '🥕',
                      rightEmoji: '🥩',
                      value: draft.vegMeatPreference,
                      onChanged: notifier.setVegMeatPreference,
                      showNumbers: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SliderCard(
                      title: '[냉동 ↔ 신선]',
                      leftLabel: '',
                      rightLabel: '',
                      leftEmoji: '🧊',
                      rightEmoji: '🍎',
                      value: draft.freshFrozenPreference,
                      onChanged: notifier.setFreshFrozenPreference,
                      showNumbers: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 평소 식사 스타일
              _SliderCard(
                title: '[평소 식사 스타일]',
                leftLabel: '건강식/일상식',
                rightLabel: '술안주/즐거움',
                leftEmoji: '🥗',
                rightEmoji: '🍺',
                value: draft.mealStyle,
                onChanged: notifier.setMealStyle,
              ),

              const SizedBox(height: 24),

              // 한달 식비 예산
              _BudgetSlider(
                value: draft.monthlyBudget,
                onChanged: notifier.setMonthlyBudget,
              ),

              const SizedBox(height: 32),

              // 에러 메시지
              if (submitState != null && submitState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '저장 실패: ${submitState.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),

              // 시작하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _onSubmit(context, ref, notifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '🪙 나만의 맞춤 식단 시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  '상세 설정은 나중에 마이페이지에서 변경 가능해요',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(
    BuildContext context,
    WidgetRef ref,
    OnboardingNotifier notifier,
  ) async {
    ref.read(submitOnboardingProvider.notifier).state =
        const AsyncValue.loading();
    try {
      final saved = await notifier.submit();
      ref.read(submitOnboardingProvider.notifier).state =
          AsyncValue.data(saved);
      if (context.mounted) {
        context.go(AppRoutes.mealStyleSelect);
      }
    } catch (e, st) {
      ref.read(submitOnboardingProvider.notifier).state =
          AsyncValue.error(e, st);
    }
  }
}

// 슬라이더 카드 위젯
class _SliderCard extends StatelessWidget {
  final String title;
  final String leftLabel;
  final String rightLabel;
  final String leftEmoji;
  final String rightEmoji;
  final int value;
  final ValueChanged<int> onChanged;
  final bool showNumbers;

  const _SliderCard({
    required this.title,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftEmoji,
    required this.rightEmoji,
    required this.value,
    required this.onChanged,
    this.showNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // 이모지 + 슬라이더
        Row(
          children: [
            Text(leftEmoji, style: const TextStyle(fontSize: 24)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryDark,
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                  thumbColor: AppColors.primaryDark,
                  overlayColor: AppColors.primaryDark.withOpacity(0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            Text(rightEmoji, style: const TextStyle(fontSize: 24)),
          ],
        ),

        // 숫자 표시
        if (showNumbers)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => Text(
                  '${i == 5 ? 10 : i * 2}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),

        // 라벨
        if (leftLabel.isNotEmpty || rightLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leftLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  rightLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// 예산 슬라이더
class _BudgetSlider extends StatelessWidget {
  const _BudgetSlider({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'ko_KR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '[한달 식비 예산]',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryDark,
            inactiveTrackColor: const Color(0xFFE0E0E0),
            thumbColor: AppColors.primaryDark,
            overlayColor: AppColors.primaryDark.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 100000,
            max: 1000000,
            divisions: 18,
            label: '${formatter.format(value)}원',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '10만원',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${formatter.format(value)}원',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const Text(
                '100만원 이상',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            '이 예산 내에서 최적의 식단을 짜드려요!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}