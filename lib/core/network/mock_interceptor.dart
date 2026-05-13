import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

/// `assets/mocks/` 의 정적 JSON 으로 응답을 가짜로 만들어 주는 Dio interceptor.
///
/// 새 mock 을 추가할 때:
///  1. `assets/mocks/<group>/<name>.json` 파일 생성
///  2. `pubspec.yaml` 의 `flutter > assets` 에 폴더 등록
///  3. 아래 [_mockMap] 에 `'METHOD /path': asset_path` 추가
class MockInterceptor extends Interceptor {
  static const Map<String, String> _mockMap = {
    'PUT /users/me/profile': 'assets/mocks/users/profile_after-onboarding.json',
    // 백엔드 팀원이 mock 을 commit 하면 여기에 매핑 추가:
    // 'POST /auth/social-login': 'assets/mocks/auth/social-login_new-user.json',
    // 'GET /meal-plan/preview':  'assets/mocks/meal-plan/preview_single-value.json',
    // ...
    'POST /meal-plans/generate': 'assets/mocks/meal-plans/generate.json',
    'GET /shopping-list': 'assets/mocks/shopping-list/shopping-list.json',
  };

  // 패턴 매칭 (신규). path parameter가 있는 엔드포인트용
  // 정규식과 mock asset 경로 쌍
  static final List<({RegExp pattern, String asset})> _mockPatterns = [
    // GET /meal-plans/{date} → 날짜 무관하게 같은 mock
    (
      pattern: RegExp(r'^GET /meal-plans/\d{4}-\d{2}-\d{2}$'),
      asset: 'assets/mocks/meal-plans/daily.json',
    ),
    // GET /menus/{meal_id} → meal_id별로 분기
    (
      pattern: RegExp(r'^GET /menus/M_001$'),
      asset: 'assets/mocks/menus/M_001.json',
    ),
    (
      pattern: RegExp(r'^GET /menus/M_002$'),
      asset: 'assets/mocks/menus/M_002.json',
    ),
    (
      pattern: RegExp(r'^GET /menus/M_003$'),
      asset: 'assets/mocks/menus/M_003.json',
    ),
    // 캘린더: 월별로 분기
    (
      pattern: RegExp(r'^GET /meal-plans/calendar\?month=2026-04$'),
      asset: 'assets/mocks/meal-plans/calendar_2026-04.json',
    ),
    (
      pattern: RegExp(r'^GET /meal-plans/calendar\?month=2026-05$'),
      asset: 'assets/mocks/meal-plans/calendar_2026-05.json',
    ),
    // 다른 달은 빈 응답 (식단 없음) — 새 파일 만들어야 함
    (
      pattern: RegExp(r'^GET /meal-plans/calendar\?month=\d{4}-\d{2}$'),
      asset: 'assets/mocks/meal-plans/calendar_empty.json',
    ),
    // 재료 가격 비교 — 재료 ID별로 분기
    (
      pattern: RegExp(r'^GET /ingredients/I_001/prices$'),
      asset: 'assets/mocks/ingredients/I_001_prices.json',
    ),
    (
      pattern: RegExp(r'^GET /ingredients/I_002/prices$'),
      asset: 'assets/mocks/ingredients/I_002_prices.json',
    ),
    (
      pattern: RegExp(r'^GET /ingredients/I_003/prices$'),
      asset: 'assets/mocks/ingredients/I_003_prices.json',
    ),
    (
      pattern: RegExp(r'^GET /ingredients/I_004/prices$'),
      asset: 'assets/mocks/ingredients/I_004_prices.json',
    ),
    (
      pattern: RegExp(r'^GET /ingredients/I_005/prices$'),
      asset: 'assets/mocks/ingredients/I_005_prices.json',
    ),
    (
      pattern: RegExp(r'^GET /ingredients/I_006/prices$'),
      asset: 'assets/mocks/ingredients/I_006_prices.json',
    ),
    (
      pattern: RegExp(r'^GET /ingredients/I_007/prices$'),
      asset: 'assets/mocks/ingredients/I_007_prices.json',
    ),
    // GET /menus/{meal_id}/alternatives → 어떤 meal_id 든 같은 mock 응답
    (
      pattern: RegExp(r'^GET /menus/M_\d+/alternatives$'),
      asset: 'assets/mocks/menus/M_001_alternatives.json',
    ),
    // PUT /meal-plans/{date}/menus/{slot} → 어떤 date·slot 이든 같은 mock 응답
    (
      pattern: RegExp(r'^PUT /meal-plans/\d{4}-\d{2}-\d{2}/menus/\d+$'),
      asset: 'assets/mocks/meal-plans/menu-change-response.json',
    ),
  ];

  /// 네트워크 지연 시뮬레이션.
  static const _simulatedLatency = Duration(milliseconds: 300);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // query parameter까지 포함한 path 생성
    final fullPath =
        options.queryParameters.isEmpty
            ? options.path
            : '${options.path}?${_encodeQuery(options.queryParameters)}';

    final key = '${options.method} $fullPath';

    // 1순위: 정확 일치
    String? assetPath = _mockMap[key];

    // 2순위: 패턴 매칭
    if (assetPath == null) {
      for (final entry in _mockPatterns) {
        if (entry.pattern.hasMatch(key)) {
          assetPath = entry.asset;
          break;
        }
      }
    }

    if (assetPath == null) {
      // mock 매핑이 없으면 그냥 진짜 HTTP 호출로 진행.
      // 실제 백엔드도 없으면 Dio 가 connection error 를 반환할 거임.
      handler.next(options);
      return;
    }

    try {
      final raw = await rootBundle.loadString(assetPath);
      final data = json.decode(raw);
      await Future.delayed(_simulatedLatency);
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: data),
      );
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Mock asset load failed: $assetPath ($e)',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  String _encodeQuery(Map<String, dynamic> params) {
    return params.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}
