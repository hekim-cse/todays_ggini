import '../domain/user.dart';
import 'auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepository(this._remote);

  Future<User> loginWithKakao(String accessToken) async {
    final raw = await _remote.loginWithKakao(accessToken);
    return User.fromJson(raw, 'kakao');
  }

  Future<User> loginWithNaver(String code) async {
    final raw = await _remote.loginWithNaver(code);
    return User.fromJson(raw, 'naver');
  }

  Future<User> loginWithGoogle(String accessToken) async {
    final raw = await _remote.loginWithGoogle(accessToken);
    return User.fromJson(raw, 'google');
  }

  Future<User> loginAsGuest() async {
    return User.guest();
  }

  Future<void> logout() async {
    await _remote.logout();
  }
}