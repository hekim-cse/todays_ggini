import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_providers.dart';

import '../../../../core/widgets/app_logo.dart';

import 'dart:ui' as ui;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<String> _selectedGoals = [];
  final List<String> _selectedFoods = [];
  final List<String> _selectedIngredient = [];
  final List<String> _allergies = [];
  final _allergyController = TextEditingController();
  String? _goalError; 
  String? _allergyError; 

  final List<String> _goals = ['식비 절약', '영양 균형', '다이어트', '고단백', '간편식', '맛 중심'];
  final List<String> _foods = ['한식', '중식', '일식', '양식', '분식', '패스트푸드', '샐러드/건강식', '다 좋아요'];
  final List<String> _ingredient = ['육류', '해산물류', '채소류', '식물성 단백질류', '계란 및 유제품류'];


  @override
  void dispose() {
    _pageController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final submitState = ref.watch(submitOnboardingProvider);
    final isSubmitting = submitState?.isLoading ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 로고
            const AppLogo(),

            const SizedBox(height: 16),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // 스와이프 막기
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                children: [
                  // 1페이지
                  _buildPage1(notifier),
                  // 2페이지
                  _buildPage2(context, ref, draft, notifier, isSubmitting, submitState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1페이지: 목적 + 취향 + 식재료 + 알레르기
  Widget _buildPage1(OnboardingNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 목적
          const Text(
            '[목적]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goals.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goal);
                      _goalError = null;
                    } else if (_selectedGoals.length < 3) {
                      _selectedGoals.add(goal);
                      _goalError = null;
                    } else {
                      _goalError = '최대 3개까지 선택이 가능합니다.';  
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _goalError = null);
                      });
                    }
                  });
                  notifier.setGoals(List.from(_selectedGoals));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // 3개 이상 선택 -> 오류 메세지 출력
          if (_goalError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _goalError!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ),

          const SizedBox(height: 32),

          // 취향
          const Text(
            '[취향]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _foods.map((food) {
              final isSelected = _selectedFoods.contains(food);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected
                        ? _selectedFoods.remove(food)
                        : _selectedFoods.add(food);
                  });
                  notifier.setFoods(List.from(_selectedFoods));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    food,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // 식재료
          const Text(
            '[선호 식재료]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ingredient.map((ingred) {
              final isSelected = _selectedIngredient.contains(ingred);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected
                        ? _selectedIngredient.remove(ingred)
                        : _selectedIngredient.add(ingred);
                  });
                  notifier.setIngredient(List.from(_selectedIngredient));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ingred,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // 알레르기 및 제외 재료
          const Text(
            '[알레르기 및 제외 재료]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // 입력창 + 추가 버튼
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _allergyController,
                      decoration: InputDecoration(
                        hintText: '제외할 재료를 입력해 주세요.',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _allergyError != null
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    // 에러 메시지
                    if (_allergyError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          _allergyError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_allergyController.text.isNotEmpty) {
                      if (_allergies.contains(_allergyController.text)) {
                        setState(() => _allergyError = '이미 입력된 재료입니다.');
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _allergyError = null);
                        });
                      } else {
                        setState(() {
                          _allergies.add(_allergyController.text);
                          _allergyController.clear();
                          _allergyError = null;
                        });
                        notifier.setAllergies(List.from(_allergies));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    '추가',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 추가된 알레르기 태그
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergies.map((allergy) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      allergy,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() => _allergies.remove(allergy));
                        notifier.setAllergies(List.from(_allergies));
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // 다음 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedGoals.isEmpty || _selectedFoods.isEmpty || _selectedIngredient.isEmpty
                  ? null  // 비활성화
                  : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceDim, // ← 비활성화 색 (회색)
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                '다음',
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
    );
  }

  // 2페이지: 다양성 + 요리실력 + 식사수 + 한달예산
  Widget _buildPage2(
    BuildContext context,
    WidgetRef ref,
    OnboardingDraft draft,
    OnboardingNotifier notifier,
    bool isSubmitting,
    AsyncValue<dynamic>? submitState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 뒤로가기 버튼
        GestureDetector(
          onTap: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
              Text(
                '이전',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        
          // 다양성
          const Text(
            '[다양성]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _DiversitySlider(
            value: draft.diversity,
            onChanged: notifier.setDiversity,
          ),

          const SizedBox(height: 32),

          // 요리 실력
          const Text(
            '[요리 실력]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _LabeledSlider(
            value: draft.cookingSkill,
            min: 1,
            max: 5,
            divisions: 4,
            getLabel: (v) {
              switch (v) {
                case 1: return '라면 정도는 끓일 수 있어요';
                case 2: return '간단한 요리는 해요';
                case 3: return '레시피를 보고 대부분 따라 할 수 있어요';
                case 4: return '웬만한 요리는 다 해요';
                case 5: return '요리가 특기예요';
                default: return '';
              }
            },
            onChanged: notifier.setCookingSkill,
          ),

          const SizedBox(height: 32),

          // 식사 수
          const Text(
            '[식사 수]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _LabeledSlider(
            value: draft.mealCount,
            min: 1,
            max: 5,
            divisions: 4,
            getLabel: (v) => '',
            onChanged: notifier.setMealCount,
          ),

          const SizedBox(height: 32),

          // 한달 식비 예산
          const Text(
            '[한달 식비 예산]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
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
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceDim,
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
                      '나만의 맞춤 식단 시작하기',
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
                color: AppColors.textHint
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit(
    BuildContext context,
    WidgetRef ref,
    OnboardingNotifier notifier,
  ) async {
    notifier.setGoals(List.from(_selectedGoals));
    notifier.setFoods(List.from(_selectedFoods));
    notifier.setIngredient(List.from(_selectedIngredient));
    notifier.setAllergies(List.from(_allergies));

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

// 다양성 슬라이더
class _DiversitySlider extends StatelessWidget {
  const _DiversitySlider({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  String _getLabel(int value) {
    if (value == 1) return '한 가지 음식만 먹어도 괜찮아요';
    if (value == 2) return '적당히 다양하게 먹고 싶어요';
    return '매일 다른 음식을 먹고 싶어요';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _getLabel(value),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDim,
            trackHeight: 6,
            thumbShape: _ImageThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1', style: TextStyle(color: AppColors.textHint)),
              Text('2', style: TextStyle(color: AppColors.textHint)),
              Text('3', style: TextStyle(color: AppColors.textHint)),
            ],
          ),
        ),
      ],
    );
  }
}

// 공통 라벨 슬라이더
class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.getLabel,
    required this.onChanged,
  });

  final int value;
  final double min;
  final double max;
  final int divisions;
  final String Function(int) getLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = getLabel(value);
    return Column(
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDim,
            trackHeight: 6,
            thumbShape: _ImageThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              divisions + 1,
              (i) => Text(
                '${(min + i).toInt()}',
                style: const TextStyle(color: AppColors.textHint),
              ),
            ),
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
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceDim,
            trackHeight: 6,
            thumbShape: _ImageThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 100000,
            max: 1000000,
            divisions: 18,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        // 숫자 (10, 100)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('10', style: TextStyle(color: AppColors.textHint)),
              Text('100', style: TextStyle(color: AppColors.textHint)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 설명 텍스트
        Center(
          child: Text(
            '${(value / 10000).round()}만원 내에서 최적의 식단을 짜드려요!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// 이미지 thumb
class _ImageThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(40, 40);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required ui.TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final paint = Paint()..color = AppColors.primary;
    context.canvas.drawCircle(center, 16, paint);
  }
}