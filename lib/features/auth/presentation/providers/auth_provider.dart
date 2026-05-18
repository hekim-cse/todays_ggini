import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/env/env.dart';
import '../../data/auth_remote_data_source.dart';
import '../../data/auth_repository.dart';
import '../../domain/user.dart';

// Repository Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authRemoteDataSourceProvider));
});

// Google Sign In Provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    clientId: Env.googleClientId,
    scopes: ['email', 'profile'],
  );
});

// State 클래스
class AuthState {
  final User? user;
  final bool isLoading;
  final Object? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => user != null;
  bool get isGuest => user?.provider == 'guest';

  AuthState copyWith({
    User? user,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier 클래스
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final GoogleSignIn _googleSignIn;

  AuthNotifier(this._repository, this._googleSignIn) : super(const AuthState());

  // 카카오 SDK → 토큰 받기 → 백엔드 전달
  Future<void> loginWithKakao() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
      final user = await _repository.loginWithKakao(token.accessToken);
      if (!mounted) return;
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  // 네이버 웹뷰 → 코드 받기 → 백엔드 전달
  Future<void> loginWithNaver() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: 'https://nid.naver.com/oauth2.0/authorize'
            '?client_id=${Env.naverClientId}'
            '&response_type=code'
            '&redirect_uri=todaysggini://auth',
        callbackUrlScheme: 'todaysggini',
      );
      final code = Uri.parse(result).queryParameters['code'] ?? '';
      final user = await _repository.loginWithNaver(code);
      if (!mounted) return;
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  // 구글 SDK → 토큰 받기 → 백엔드 전달
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final auth = await account.authentication;
      final accessToken = auth.accessToken ?? '';
      final user = await _repository.loginWithGoogle(accessToken);
      if (!mounted) return;
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  Future<void> loginAsGuest() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.loginAsGuest();
      if (!mounted) return;
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _googleSignIn.signOut();
      await _repository.logout();
      if (!mounted) return;
      state = const AuthState();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(googleSignInProvider),
  ),
);