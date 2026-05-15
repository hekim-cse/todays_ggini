import '../domain/user_profile.dart';
import 'onboarding_remote_data_source.dart';

/// Domain ↔ Data 변환 담당.
///
/// Presentation 계층은 Repository 만 알면 되고,
/// 백엔드 API 가 바뀌면 이 파일과 [OnboardingRemoteDataSource] 만 수정하면 끝.
class OnboardingRepository {
  OnboardingRepository(this._remote);

  final OnboardingRemoteDataSource _remote;

  /// 슬라이더 입력값을 서버에 저장하고, 저장된 프로필을 반환.
  Future<UserProfile> saveProfile(UserProfile profile) async {
    // final raw = await _remote.putProfile(profile.toJson());
    // final profileJson = raw['profile'] as Map<String, dynamic>;
    // return UserProfile.fromJson(profileJson);
    // TODO(jungsoo): 임시 테스트용으로 추후에 제거하고 위로 복원 — 백엔드 응답이 {id, is_onboarded} 두 필드만 줘서
    // 기존 raw['profile'] 파싱이 깨짐. 일단 응답 파싱 무시하고
    // 입력 profile 그대로 반환. onboarding 담당자가 정식으로 정리해야 함.
    await _remote.putProfile(profile.toJson());
    return profile;
  }
}
