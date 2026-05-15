import '../../../../core/utils/result.dart';
import '../entities/story.dart';

abstract class StoryRepository {
  Future<Result<List<Story>>> getTopStories({
    required int page,
    required int pageSize,
  });
  Future<Result<Story>> getStory(int id);
}
