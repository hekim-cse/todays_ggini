import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/api_client.dart';
import 'core/auth/token_store.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class KkiniPickApp extends ConsumerWidget {
  const KkiniPickApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return _DemoBootstrap(
      child: MaterialApp.router(
        title: '오늘의 끼니',
        theme: AppTheme.light(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// TODO(jungsoo): 인증/온보딩 담당자 영역이 정식 구현되면 제거.
//
// 임시로 메우는 자리 = signup + login 두 단계만.
// (소셜 로그인 화면이 디자인 단계라 인증 흐름을 우회해야 함)
//
// 그 외 사용자 입력 → 서버 전송은 본인이 만든 화면이 정상 처리:
//   - onboarding 화면 → PATCH /user/onboarding (saveProfile)
//   - meal_style_select 화면 → POST /meal/request_monthly_plan
//
// 부트스트랩 완료 전까지는 로딩 화면. 끝나면 라우터의 첫 화면 (splash) 으로 진입.
// 각 단계 진행은 debugPrint 로 터미널에 출력 — release 빌드에선 자동 제거됨.
class _DemoBootstrap extends ConsumerStatefulWidget {
  final Widget child;
  const _DemoBootstrap({required this.child});

  @override
  ConsumerState<_DemoBootstrap> createState() => _DemoBootstrapState();
}

class _DemoBootstrapState extends ConsumerState<_DemoBootstrap> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final dio = ref.read(dioProvider);

    try {
      debugPrint('=========== DEMO BOOTSTRAP START ===========');

      // 1. signup (이미 있으면 200 으로 기존 유저 반환)
      debugPrint('[1/2] POST /user/signup ...');
      final signupRes = await dio.post(
        '/user/signup',
        queryParameters: {
          'provider': 'guest',
          'social_id': 'demo_user_001',
          'email': 'demo@kkini.local',
        },
      );
      debugPrint('  → response: ${signupRes.data}');

      // 2. login → 토큰 → TokenStore 저장
      debugPrint('[2/2] POST /auth/login ...');
      final loginRes = await dio.post(
        '/auth/login',
        data: {'provider': 'guest', 'social_id': 'demo_user_001'},
      );
      final token = loginRes.data['access_token'] as String;
      debugPrint('  → token received:');
      debugPrint('    $token');
      ref.read(tokenStoreProvider.notifier).setToken(token);
      debugPrint('  → token stored in TokenStore');

      debugPrint('=========== DEMO BOOTSTRAP DONE  ===========');

      if (!mounted) return;
      setState(() => _ready = true);
    } catch (e, stack) {
      debugPrint('=========== DEMO BOOTSTRAP FAILED ==========');
      debugPrint('  error: $e');
      debugPrint('  stack: $stack');
      if (!mounted) return;
      setState(() {
        _ready = true; // 실패해도 child 렌더 — 수동 복구 여지 남김
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('데모 데이터 준비 중...'),
                SizedBox(height: 8),
                Text(
                  '터미널에서 진행 상황 확인 가능',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null && kDebugMode) {
      debugPrint('[demo bootstrap] proceeding despite error: $_error');
    }

    return widget.child;
  }
}
