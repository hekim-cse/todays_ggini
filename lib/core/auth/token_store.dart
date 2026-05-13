import 'package:flutter_riverpod/legacy.dart';

// JWT access token 저장소
//
// 인증 담당자가 로그인 성공 후 [setToken] 으로 토큰을 저장하고,
// 로그아웃 시 [clear] 로 비움
// 네트워크 계층의 AuthInterceptor 가 매 요청마다 이 값을 읽어 헤더에 부착.
//
// 현재는 메모리에만 저장 (앱 재시작 시 사라짐)
// 영속화 필요 시 SharedPreferences 또는 flutter_secure_storage 로 확장
class TokenStoreNotifier extends StateNotifier<String?> {
  TokenStoreNotifier() : super(null);

  /// 로그인 성공 후 토큰 저장.
  void setToken(String? token) {
    state = (token != null && token.isNotEmpty) ? token : null;
  }

  /// 로그아웃 시 토큰 제거.
  void clear() {
    state = null;
  }
}

final tokenStoreProvider = StateNotifierProvider<TokenStoreNotifier, String?>(
  (ref) => TokenStoreNotifier(),
);
