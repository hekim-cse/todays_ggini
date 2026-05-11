import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../widgets/profile_section.dart';
import '../widgets/section_title.dart';
import '../widgets/setting_item.dart';

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '[$title]',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = temp.contains(option);
              return GestureDetector(
                onTap: () {
                  setDialogState(() {
                    if (isSelected) {
                      temp.remove(option);
                    } else if (temp.length < maxSelect) {
                      temp.add(option);
                    }
                  });
                },
                child: Container(
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
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => onConfirm(temp));
              },
              child: Text(
                '확인',
                style: TextStyle(color: AppColors.primary),
              ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('[$title]', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getLabel(temp),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceDim,
                  thumbColor: AppColors.primary,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: temp.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: max - min,
                  onChanged: (v) => setDialogState(() => temp = v.round()),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => onConfirm(temp));
              },
              child: Text('확인', style: TextStyle(color: AppColors.primary)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('[한달 식비 예산]', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(temp / 10000).round()}만원 내에서 최적의 식단을 짜드려요!',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceDim,
                  thumbColor: AppColors.primary,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: temp.toDouble(),
                  min: 100000,
                  max: 1000000,
                  divisions: 18,
                  onChanged: (v) => setDialogState(() => temp = v.round()),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _monthlyBudget = temp);
              },
              child: Text('확인', style: TextStyle(color: AppColors.primary)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('[제외 재료]', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: '제외할 재료 입력',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: error != null ? AppColors.error : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        if (temp.contains(controller.text)) {
                          setDialogState(() => error = '이미 입력된 재료입니다.');
                          Future.delayed(const Duration(seconds: 2), () {
                            setDialogState(() => error = null);
                          });
                        } else {
                          setDialogState(() {
                            temp.add(controller.text);
                            controller.clear();
                            error = null;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('추가', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: temp.map((allergy) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(allergy, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setDialogState(() => temp.remove(allergy)),
                        child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _allergies = temp);
              },
              child: Text('확인', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('로그아웃', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠어요?\n모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('탈퇴하기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            ProfileSection(persona: _persona),

            const SizedBox(height: 24),

            // 내 설정
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

            // 앱 설정
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

            // 계정 설정
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