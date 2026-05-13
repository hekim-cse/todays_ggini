import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_store.dart';
import '../env/env.dart';
import 'auth_interceptor.dart';
import 'mock_interceptor.dart';

/// 앱 전체에서 공유하는 Dio 인스턴스.
/// - [AuthInterceptor] 가 매 요청마다 토큰을 헤더에 부착 (mock/실서버 공통)
/// `USE_MOCKS=true` 일 때 [MockInterceptor] 가 자동으로 mock JSON 을 반환.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  // AuthInterceptor 먼저 — 헤더 부착.
  // ref.read 로 매번 fresh 한 토큰을 읽음 (token 변경 시 dio 재생성 없이 자동 반영).
  dio.interceptors.add(AuthInterceptor(() => ref.read(tokenStoreProvider)));

  // MockInterceptor 는 mock 모드에서만
  if (Env.useMocks) {
    dio.interceptors.add(MockInterceptor());
  }

  // TODO: 추후 추가
  // - ErrorInterceptor (4xx/5xx 를 도메인 예외로 변환)
  // - LogInterceptor (debug 빌드에서만)

  return dio;
});
