import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_client.dart';
import '../../data/mypage_remote_data_source.dart';
import '../../data/mypage_repository.dart';
import '../../domain/my_profile.dart';

final myPageRemoteProvider = Provider<MyPageRemoteDataSource>((ref) {
  return MyPageRemoteDataSource(ref.watch(dioProvider));
});

final myPageRepositoryProvider = Provider<MyPageRepository>((ref) {
  return MyPageRepository(ref.watch(myPageRemoteProvider));
});

class MyPageState {
  final MyProfile? profile;
  final bool isLoading;
  final Object? error;

  const MyPageState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  MyPageState copyWith({
    MyProfile? profile,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return MyPageState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyPageNotifier extends StateNotifier<MyPageState> {
  MyPageNotifier(this._repository) : super(const MyPageState());

  final MyPageRepository _repository;

  Future<void> fetchMyProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repository.fetchMyProfile();
      if (!mounted) return;
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }
}

final myPageProvider = StateNotifierProvider<MyPageNotifier, MyPageState>((ref) {
  return MyPageNotifier(ref.watch(myPageRepositoryProvider));
});