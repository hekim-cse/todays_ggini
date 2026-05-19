class User {
  final String id;
  final String? nickname;
  final String? email;
  final String provider; // 'kakao', 'naver', 'google', 'guest'
  final String? accessToken;
  final String? refreshToken;
  final bool isOnboarded;

  const User({
    required this.id,
    required this.provider,
    this.nickname,
    this.email,
    this.accessToken,
    this.refreshToken,
    this.isOnboarded = false,
  });

  factory User.fromJson(Map<String, dynamic> json, String provider) {
    final user = json['user'] as Map<String, dynamic>?;
    
    if (user != null) {
      // 소셜 로그인 응답 (user 객체 있음)
      return User(
        id: user['id'].toString(),
        provider: provider,
        nickname: user['nickname'] as String?,
        email: user['email'] as String?,
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?,
        isOnboarded: user['is_onboarded'] as bool? ?? false,
      );
    } else {
      // 게스트 로그인 응답 (accessToken만 있음)
      return User(
        id: 'guest',
        provider: provider,
        accessToken: json['accessToken'] as String?,
        isOnboarded: false,
      );
    }
  }
}