import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/social_login_sheet.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/calendar.png',
      'message': '여기는 캘린더 화면이야!\n한 달 총 비용과 평균 칼로리를\n확인할 수 있고, 언제 어떤\n음식을 먹는지 알 수 있어.',
    },
    {
      'image': 'assets/images/home.png',
      'message': '여기는 홈 화면이야!\n레시피 영상을 볼 수 있고 필요한\n재료와 마켓별 가격 비교를 통해\n최저가를 확인할 수 있어.',
    },
    {
      'image': 'assets/images/shopping.png',
      'message': '여기는 장보기 화면이야!\n마켓별로 재료를 묶어서 볼 수\n있고 원하는 재료만 선택해서\n구매할 수도 있어.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showLoginSheet();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => const SocialLoginSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 상단 진행바
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: List.generate(_pages.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index < _pages.length - 1 ? 4 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: index == _currentPage
                                ? AppColors.primary
                                : AppColors.buttonGray,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 이전 / 다음 안내 문구
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '<< 이전',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: _currentPage > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                      ),

                      Text(
                        _currentPage < _pages.length - 1
                            ? '>> 다음'
                            : '시작하기',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),

                // 메인 이미지 + 기니피그
                Expanded(
                  child: PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: Stack(
                          children: [
                            // 메인 이미지
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  _pages[index]['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),

                            // 기니피그 + 말풍선
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Transform.translate(
                                offset: const Offset(0, 40),
                                child: SizedBox(
                                  width: 500,
                                  child: AspectRatio(
                                    aspectRatio: 1.2,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.asset(
                                            'assets/images/auth_ggini.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),

                                        Align(
                                          alignment: Alignment(-0.50, -0.07),
                                          child: FractionallySizedBox(
                                            widthFactor: 0.6,
                                            heightFactor: 0.5,
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                child: Text(
                                                  _pages[index]['message']!,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 4,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 전체 화면 터치 영역
            Row(
              children: [
                // 왼쪽 반
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _previousPage,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // 오른쪽 반
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _nextPage,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}