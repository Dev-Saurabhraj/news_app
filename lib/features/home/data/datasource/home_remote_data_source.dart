import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/story_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<int>> getTopStoryIds();
  Future<StoryModel?> getStory(int id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<int>> getTopStoryIds() async {
    final data = await _client.get<List<dynamic>>(ApiConstants.topStories);
    return data.cast<int>();
  }

  @override
  Future<StoryModel?> getStory(int id) async {
    final data = await _client.get<Map<String, dynamic>>(ApiConstants.item(id));
    if (data['deleted'] == true ||
        data['dead'] == true ||
        data['type'] != 'story') {
      return null;
    }
    return StoryModel.fromJson(data);
  }
}
