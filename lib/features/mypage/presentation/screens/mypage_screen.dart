import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../widgets/profile_section.dart';
import '../widgets/section_title.dart';
import '../widgets/setting_item.dart';
import '../../../../core/widgets/popup.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String _persona = '맛과 밸런스';
  List<String> _goals = ['식비 절약', '간편식', '맛 중심'];
  List<String> _foods = ['한식', '일식', '패스트푸드'];
  List<String> _ingredients = ['육류', '채소류'];
  List<String> _allergies = ['우유', '새우'];
  int _diversity = 2;
  int _cookingSkill = 4;
  int _mealCount = 4;
  int _monthlyBudget = 400000;

  final List<String> _goalOptions = ['식비 절약', '영양 균형', '다이어트', '고단백', '간편식', '맛 중심'];
  final List<String> _foodOptions = ['한식', '중식', '일식', '양식', '분식', '패스트푸드', '샐러드/건강식', '다 좋아요'];
  final List<String> _ingredientOptions = ['육류', '해산물류', '채소류', '식물성 단백질류', '계란 및 유제품류'];

  String _formatList(List<String> list) {
    if (list.isEmpty) return '없음';
    if (list.length <= 2) return list.join(', ');
    return '${list.take(2).join(', ')}, ...';
  }

  Widget _buildChips(BuildContext context, List<String> options, List<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.buttonGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            option,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSliderContent(BuildContext context, int value, int min, int max, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            disabledActiveTrackColor: AppColors.primary,
            disabledInactiveTrackColor: AppColors.buttonGray,
            disabledThumbColor: AppColors.primary,
            trackHeight: 6,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: null,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$min', style: Theme.of(context).textTheme.bodySmall,),
            Text('$max', style: Theme.of(context).textTheme.bodySmall,),
          ],
        ),
      ],
    );
  }

  void _showChipDialog(String title, List<String> options, List<String> selected) {
    showAppPopupWidget(
      context: context,
      title: '[$title]',
      contentWidget: _buildChips(context, options, selected),
      leftButtonText: '재설정하기',
      rightButtonText: '확인',
      leftButtonColor: AppColors.primary,
      rightButtonColor: AppColors.textSecondary,
      onLeftTap: () {
        Navigator.pop(context);
        context.go(AppRoutes.onboarding);
      },
      onRightTap: () => Navigator.pop(context),
    );
  }

  void _showSliderDialog(String title, int value, int min, int max, String Function(int) getLabel) {
    showAppPopupWidget(
      context: context,
      title: '[$title]',
      contentWidget: _buildSliderContent(context, value, min, max, getLabel(value)),
      leftButtonText: '재설정하기',
      rightButtonText: '확인',
      leftButtonColor: AppColors.textSecondary,
      rightButtonColor: AppColors.primary,
      onLeftTap: () {
        Navigator.pop(context);
        context.go(AppRoutes.onboarding);
      },
      onRightTap: () => Navigator.pop(context),
    );
  }

  void _showBudgetDialog() {
    showAppPopupWidget(
      context: context,
      title: '[한달 식비 예산]',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${(_monthlyBudget / 10000).round()}만원 내에서 최적의 식단을 짜드려요!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              disabledActiveTrackColor: AppColors.primary,
              disabledInactiveTrackColor: AppColors.buttonGray,
              disabledThumbColor: AppColors.primary,
              trackHeight: 6,
            ),
            child: Slider(
              value: _monthlyBudget.toDouble(),
              min: 100000,
              max: 1000000,
              divisions: 18,
              onChanged: null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10만원', style: Theme.of(context).textTheme.bodySmall,),
              Text('100만원', style: Theme.of(context).textTheme.bodySmall,),
            ],
          ),
        ],
      ),
      leftButtonText: '재설정하기',
      rightButtonText: '확인',
      leftButtonColor: AppColors.primary,
      rightButtonColor: AppColors.textSecondary,
      onLeftTap: () {
        Navigator.pop(context);
        context.go(AppRoutes.onboarding);
      },
      onRightTap: () => Navigator.pop(context),
    );
  }

  void _showAllergyDialog() {
    showAppPopupWidget(
      context: context,
      title: '[제외 재료]',
      contentWidget: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _allergies.map((allergy) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.buttonGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            allergy,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )).toList(),
      ),
      leftButtonText: '재설정하기',
      rightButtonText: '확인',
      leftButtonColor: AppColors.primary,
      rightButtonColor: AppColors.textSecondary,
      onLeftTap: () {
        Navigator.pop(context);
        context.go(AppRoutes.onboarding);
      },
      onRightTap: () => Navigator.pop(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showAppPopup(
      context: context,
      content: '정말 로그아웃 하시겠어요?',
      leftButtonText: '취소',
      rightButtonText: '로그아웃',
      onLeftTap: () => Navigator.pop(context),
      onRightTap: () => Navigator.pop(context),
      rightButtonColor: AppColors.textSecondary,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showAppPopup(
      context: context,
      content: '정말 탈퇴하시겠어요?\n모든 데이터가 삭제됩니다.',
      leftButtonText: '취소',
      rightButtonText: '탈퇴하기',
      onLeftTap: () => Navigator.pop(context),
      onRightTap: () => Navigator.pop(context),
      rightButtonColor: AppColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileSection(persona: _persona),
              const SizedBox(height: 24),

              const SectionTitle(title: '내 설정'),

              SettingItem(
                emoji: '😊',
                title: '페르소나',
                value: _persona,
                onTap: () {},
              ),

              SettingItem(
                emoji: '✅',
                title: '목적',
                value: _formatList(_goals),
                onTap: () => _showChipDialog(
                  '목적',
                  _goalOptions,
                  _goals,
                ),
              ),

              SettingItem(
                emoji: '🥨',
                title: '취향',
                value: _formatList(_foods),
                onTap: () => _showChipDialog(
                  '취향',
                  _foodOptions,
                  _foods,
                ),
              ),

              SettingItem(
                emoji: '🥦',
                title: '선호 식재료',
                value: _formatList(_ingredients),
                onTap: () => _showChipDialog(
                  '선호 식재료',
                  _ingredientOptions,
                  _ingredients,
                ),
              ),

              SettingItem(
                emoji: '🫙',
                title: '제외 재료',
                value: _formatList(_allergies),
                onTap: () => _showAllergyDialog(),
              ),

              SettingItem(
                emoji: '🍱',
                title: '다양성',
                value: '$_diversity단계',
                onTap: () => _showSliderDialog(
                  '다양성',
                  _diversity,
                  1,
                  3,
                  (v) {
                    if (v == 1) {
                      return '한 가지 음식만 먹어도 괜찮아요';
                    }
                    if (v == 2) {
                      return '적당히 다양하게 먹고 싶어요';
                    }
                    return '매일 다른 음식을 먹고 싶어요';
                  },
                ),
              ),

              SettingItem(
                emoji: '🍳',
                title: '요리 실력',
                value: '$_cookingSkill단계',
                onTap: () => _showSliderDialog(
                  '요리 실력',
                  _cookingSkill,
                  1,
                  5,
                  (v) {
                    switch (v) {
                      case 1:
                        return '라면도 태워요';
                      case 2:
                        return '간단한 요리는 해요';
                      case 3:
                        return '레시피를 보고 대부분 따라 할 수 있어요';
                      case 4:
                        return '웬만한 요리는 다 해요';
                      case 5:
                        return '요리가 특기예요';
                      default:
                        return '';
                    }
                  },
                ),
              ),

              SettingItem(
                emoji: '🍚',
                title: '식사 수',
                value: '$_mealCount끼',
                onTap: () => _showSliderDialog(
                  '식사 수',
                  _mealCount,
                  1,
                  5,
                  (v) => '$v끼 먹어요',
                ),
              ),

              SettingItem(
                emoji: '💰',
                title: '한달 식비 예산',
                value: '${(_monthlyBudget / 10000).round()}만원',
                onTap: () => _showBudgetDialog(),
              ),

              const SizedBox(height: 24),

              const SectionTitle(title: '앱 설정'),

              SettingItem(
                emoji: '🔔',
                title: '알림 설정',
                value: '',
                onTap: () {},
                showToggle: true,
                showArrow: false,
              ),

              const SizedBox(height: 24),

              const SectionTitle(title: '계정 설정'),

              SettingItem(
                emoji: '🚪',
                title: '로그아웃',
                value: '',
                onTap: () => _showLogoutDialog(context),
                showArrow: false,
              ),

              SettingItem(
                emoji: '⚠️',
                title: '회원탈퇴',
                value: '',
                titleColor: AppColors.error,
                onTap: () => _showDeleteAccountDialog(context),
                showArrow: false,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}