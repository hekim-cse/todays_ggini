import '../domain/my_profile.dart';
import 'mypage_remote_data_source.dart';

class MyPageRepository {
  MyPageRepository(this._remote);
  final MyPageRemoteDataSource _remote;

  Future<MyProfile> fetchMyProfile() async {
    final raw = await _remote.fetchMyProfile();
    return MyProfile.fromJson(raw);
  }
}