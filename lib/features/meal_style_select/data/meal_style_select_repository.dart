import '../domain/meal_style.dart';
import 'meal_style_select_remote_data_source.dart';

class MealStyleSelectRepository {
  MealStyleSelectRepository(this._remote);
  final MealStyleSelectRemoteDataSource _remote;

  Future<List<MealStyle>> fetchStyleCandidates() async {
    final raw = await _remote.fetchStyleCandidates();
    final candidates = raw['candidates'] as List;
    return candidates
        .map((e) => MealStyle.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}