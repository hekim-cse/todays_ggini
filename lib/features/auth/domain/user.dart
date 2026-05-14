class User {
  final String id;
  final String? name;
  final String? email;
  final String provider; // 'kakao', 'naver', 'google', 'apple', 'guest'
  final String? accessToken;

  const User({
    required this.id,
    required this.provider,
    this.name,
    this.email,
    this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      provider: json['provider'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider': provider,
    'name': name,
    'email': email,
    'access_token': accessToken,
  };

  // 게스트 유저
  factory User.guest() {
    return const User(
      id: 'guest',
      provider: 'guest',
    );
  }
}