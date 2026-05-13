import 'package:dio/dio.dart';

// JWT 토큰을 Authorization 헤더에 자동 부착하는 Dio 인터셉터
//
// [tokenGetter] 는 매 요청마다 호출되어 최신 토큰 값을 반환해야 함
// 보통 `() => ref.read(tokenStoreProvider)` 형태로 넘김
//
// 토큰이 null 또는 빈 문자열이면 헤더를 부착하지 않음 (비로그인 상태)
class AuthInterceptor extends Interceptor {
  final String? Function() _tokenGetter;

  AuthInterceptor(this._tokenGetter);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
