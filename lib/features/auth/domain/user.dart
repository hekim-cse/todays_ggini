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
    final user = json['user'] as Map<String, dynamic>;
    return User(
      id: user['id'].toString(), // int → String 변환
      provider: provider,
      nickname: user['nickname'] as String?,
      email: user['email'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isOnboarded: user['is_onboarded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider': provider,
    'nickname': nickname,
    'email': email,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'is_onboarded': isOnboarded,
  };

  // 게스트 유저
  factory User.guest() {
    return const User(
      id: 'guest',
      provider: 'guest',
      isOnboarded: false,
    );
  }
}