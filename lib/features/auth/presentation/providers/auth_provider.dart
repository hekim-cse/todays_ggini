import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_client.dart';
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

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> loginWithKakao(String accessToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.loginWithKakao(accessToken);
      if (!mounted) return;
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  Future<void> loginWithNaver(String accessToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.loginWithNaver(accessToken);
      if (!mounted) return;
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  Future<void> loginWithGoogle(String accessToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.loginWithGoogle(accessToken);
      if (!mounted) return;
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  Future<void> loginWithApple(String identityToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.loginWithApple(identityToken);
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
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);