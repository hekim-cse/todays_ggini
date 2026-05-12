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

  // 공통 팝업 액션 버튼
  Widget _buildActions(BuildContext ctx, VoidCallback onConfirm, VoidCallback onReset) {
    return Column(
      children: [
        Divider(height: 1, color: AppColors.textSecondary),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await Future.delayed(Duration.zero); // ← 팝업 완전히 닫힌 후 이동
                  onReset();
                },
                child: const Text(
                  '재설정하기',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.textSecondary),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  '확인',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showChipDialog(
    String title,
    List<String> options,
    List<String> selected,
    Function(List<String>) onConfirm, {
    int maxSelect = 99,
  }) {
    List<String> temp = List.from(selected);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '[$title]',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selected.contains(option); // temp 대신 selected 원본
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            _buildActions(
              ctx,
              () => Navigator.pop(ctx),
              () {
                if (mounted) context.go(AppRoutes.onboarding);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSliderDialog(
    String title,
    int value,
    int min,
    int max,
    String Function(int) getLabel,
    Function(int) onConfirm,
  ) {
    int temp = value;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '[$title]',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getLabel(temp),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  disabledActiveTrackColor: AppColors.primary,
                  disabledInactiveTrackColor: AppColors.surfaceDim,
                  disabledThumbColor: AppColors.primary,

                  trackHeight: 6,
                ),
                child: Slider(
                  value: temp.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: max - min,
                  onChanged: null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$min', style: const TextStyle(color: AppColors.textHint)),
                  Text('$max', style: const TextStyle(color: AppColors.textHint)),
                ],
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            _buildActions(
              ctx,
              () => Navigator.pop(ctx),
              () {
                if (mounted) context.go(AppRoutes.onboarding);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetDialog() {
    int temp = _monthlyBudget;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '[한달 식비 예산]',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(temp / 10000).round()}만원 내에서 최적의 식단을 짜드려요!',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  disabledActiveTrackColor: AppColors.primary,
                  disabledInactiveTrackColor: AppColors.surfaceDim,
                  disabledThumbColor: AppColors.primary,

                  trackHeight: 6,
                ),
                child: Slider(
                  value: temp.toDouble(),
                  min: 100000,
                  max: 1000000,
                  divisions: 18,
                  onChanged: null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('10만원', style: TextStyle(color: AppColors.textHint)),
                  Text('100만원', style: TextStyle(color: AppColors.textHint)),
                ],
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            _buildActions(
              ctx,
              () => Navigator.pop(ctx),
              () {
                if (mounted) context.go(AppRoutes.onboarding);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllergyDialog() {
    List<String> temp = List.from(_allergies);
    final controller = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '[제외 재료]',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergies.map((allergy) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                allergy,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            )).toList(),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            _buildActions(
              ctx,
              () => Navigator.pop(ctx),
              () {
                if (mounted) context.go(AppRoutes.onboarding);
              },
            ),
          ],
        ),
      ),
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
      rightButtonColor: AppColors.primary,
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
      rightButtonColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
                '목적', _goalOptions, _goals,
                (v) => _goals = v,
                maxSelect: 3,
              ),
            ),
            SettingItem(
              emoji: '🥨',
              title: '취향',
              value: _formatList(_foods),
              onTap: () => _showChipDialog(
                '취향', _foodOptions, _foods,
                (v) => _foods = v,
              ),
            ),
            SettingItem(
              emoji: '🥦',
              title: '선호 식재료',
              value: _formatList(_ingredients),
              onTap: () => _showChipDialog(
                '선호 식재료', _ingredientOptions, _ingredients,
                (v) => _ingredients = v,
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
                '다양성', _diversity, 1, 3,
                (v) {
                  if (v == 1) return '한 가지 음식만 먹어도 괜찮아요';
                  if (v == 2) return '적당히 다양하게 먹고 싶어요';
                  return '매일 다른 음식을 먹고 싶어요';
                },
                (v) => _diversity = v,
              ),
            ),
            SettingItem(
              emoji: '🍳',
              title: '요리 실력',
              value: '$_cookingSkill단계',
              onTap: () => _showSliderDialog(
                '요리 실력', _cookingSkill, 1, 5,
                (v) {
                  switch (v) {
                    case 1: return '라면도 태워요';
                    case 2: return '간단한 요리는 해요';
                    case 3: return '레시피를 보고 대부분 따라 할 수 있어요';
                    case 4: return '웬만한 요리는 다 해요';
                    case 5: return '요리가 특기예요';
                    default: return '';
                  }
                },
                (v) => _cookingSkill = v,
              ),
            ),
            SettingItem(
              emoji: '🍚',
              title: '식사 수',
              value: '$_mealCount끼',
              onTap: () => _showSliderDialog(
                '식사 수', _mealCount, 1, 5,
                (v) => '$v끼 먹어요',
                (v) => _mealCount = v,
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
              titleColor: Colors.red,
              onTap: () => _showDeleteAccountDialog(context),
              showArrow: false,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}