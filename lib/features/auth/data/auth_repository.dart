import '../domain/user.dart';
import 'auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepository(this._remote);

  Future<User> loginWithKakao(String accessToken) async {
    final raw = await _remote.loginWithKakao(accessToken);
    return User.fromJson(raw);
  }

  Future<User> loginWithNaver(String accessToken) async {
    final raw = await _remote.loginWithNaver(accessToken);
    return User.fromJson(raw);
  }

  Future<User> loginWithGoogle(String accessToken) async {
    final raw = await _remote.loginWithGoogle(accessToken);
    return User.fromJson(raw);
  }

  Future<User> loginWithApple(String identityToken) async {
    final raw = await _remote.loginWithApple(identityToken);
    return User.fromJson(raw);
  }

  // 게스트 로그인은 API 호출 없이 바로 반환
  Future<User> loginAsGuest() async {
    return User.guest();
  }

  Future<void> logout() async {
    await _remote.logout();
  }
}