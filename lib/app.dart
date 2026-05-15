import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/api_client.dart';
import 'core/auth/token_store.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// TODO(jungsoo): 인증 화면 통합 후 삭제할 임시 토큰 주입.
// Swagger UI 의 POST /api/v1/auth/guest/init 응답에서 받은 토큰을 그대로 붙여넣기.
// 비어있으면 주입 안 함 (mock 모드 또는 비로그인 상태 그대로 동작).
const String _kDebugBearerToken = '비밀입니다';

class KkiniPickApp extends ConsumerStatefulWidget {
  const KkiniPickApp({super.key});

  @override
  ConsumerState<KkiniPickApp> createState() => _KkiniPickAppState();
}

class _KkiniPickAppState extends ConsumerState<KkiniPickApp> {
  @override
  void initState() {
    super.initState();
    // 첫 프레임 그려진 후 토큰 주입 — Riverpod 가 안정 상태일 때 read.
    if (_kDebugBearerToken.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tokenStoreProvider.notifier).setToken(_kDebugBearerToken);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '오늘의 끼니', // 앱 이름
      theme: AppTheme.light(), // 앱의 밝은 테마 적용
      routerConfig: router, // 화면 이동 설정 적용
      debugShowCheckedModeBanner: false, // 오른쪽 위 DEBUG 배너 숨김
    );
  }
}

// TODO(jungsoo): 발표 끝나면 제거. 정식 인증 흐름으로 교체.
class _DemoBootstrap extends ConsumerStatefulWidget {
  final Widget child;
  const _DemoBootstrap({required this.child});
  @override
  ConsumerState createState() => _DemoBootstrapState();
}

class _DemoBootstrapState extends ConsumerState<_DemoBootstrap> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    final dio = ref.read(dioProvider);

    try {
      // 1. signup (이미 있으면 200 으로 기존 유저 반환)
      await dio.post(
        '/user/signup',
        queryParameters: {
          'provider': 'demo',
          'social_id': 'demo_user_001',
          'email': 'demo@kkini.local',
        },
      );

      // 2. 로그인 → 토큰
      final loginRes = await dio.post(
        '/auth/login',
        data: {'provider': 'demo', 'social_id': 'demo_user_001'},
      );
      final token = loginRes.data['access_token'] as String;
      ref.read(tokenStoreProvider.notifier).setToken(token);

      // 3. 온보딩 데이터 (이미 onboarded 면 그냥 덮어쓰기 됨)
      await dio.patch(
        '/user/onboarding',
        data: {
          'persona_id': 1,
          'meals_per_day': 3,
          'purposes': ['영양 균형', '식비 절약'],
          'monthly_budget': 100000,
          'cooking_skill': 2,
          'diversity_level': '보통',
          'preferred_categories': ['한식'],
          'preferred_ingredients': [],
          'excluded_ingredients': [],
        },
      );

      // 4. 월간 식단 시드 (이미 시드돼있으면 백엔드가 알아서 처리해야 함)
      await dio.post(
        '/meal/request_monthly_plan',
        data: {'selected_style_id': 'style_balanced'},
      );

      _bootstrapped = true;
    } catch (e) {
      // 시연 중 실패 시 콘솔에서만 확인
      debugPrint('[demo bootstrap] failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
