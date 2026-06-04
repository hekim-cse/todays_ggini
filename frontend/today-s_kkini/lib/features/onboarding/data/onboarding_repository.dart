import '../domain/user_profile.dart';
import 'onboarding_remote_data_source.dart';

class OnboardingRepository {
  OnboardingRepository(this._remote);

  final OnboardingRemoteDataSource _remote;

  Future<void> saveProfile(UserProfile profile) async {
    await _remote.postOnboarding(profile.toJson());
  }
}