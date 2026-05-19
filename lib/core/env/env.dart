/// 환경변수. compile-time 주입.
///
/// 사용 예:
///   flutter run --dart-define=USE_MOCKS=true
///   flutter run --dart-define=USE_MOCKS=false --dart-define=API_BASE_URL=https://...
class Env {
  const Env._();

  /// true 이면 mock JSON 응답을 사용 (백엔드 미구현 시).
  static const bool useMocks = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: false,
  );

  /// 백엔드 base URL.
  // static const String apiBaseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'http://192.168.219.100:8000/',
  // );
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://blissful-survival-channel.ngrok-free.dev/',
  );

  /// 카카오 네이티브 앱 키.
  static const String kakaoNativeKey = String.fromEnvironment(
    'KAKAO_NATIVE_KEY',
    defaultValue: '9eb912137d7833c4bda844bebcce1a3c',
  );

  /// 네이버 Client ID.
  static const String naverClientId = String.fromEnvironment(
    'NAVER_CLIENT_ID',
    defaultValue: 'LaLqTUwNHmjlcUpO4Mlv',
  );

  /// 네이버 Client Secret.
  static const String naverClientSecret = String.fromEnvironment(
    'NAVER_CLIENT_SECRET',
    defaultValue: '',
  );

  /// 구글 Client ID.
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '987643896621-4mr99pgantk7l6tq6quupq2bvkfiunp4.apps.googleusercontent.com',
  );
}
