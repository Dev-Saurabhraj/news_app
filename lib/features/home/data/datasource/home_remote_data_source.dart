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
    try {
      final data = await _client.get<List<dynamic>>(ApiConstants.topStories);
      if (data.isEmpty) {
        return <int>[];
      }
      // Safely cast to int, filtering out non-integer values
      final storyIds = <int>[];
      for (final item in data) {
        if (item is int) {
          storyIds.add(item);
        }
      }
      return storyIds;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<StoryModel?> getStory(int id) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiConstants.item(id),
      );

      // Check for null or deleted/dead items
      if (data.isEmpty) return null;
      if (data['deleted'] == true || data['dead'] == true) return null;
      if (data['type'] != 'story') return null;

      // Validate required fields before parsing
      if (data['id'] == null) return null;

      return StoryModel.fromJson(data);
    } catch (error) {
      rethrow;
    }
  }
}
