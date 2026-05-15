import '../../../../core/utils/result.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

class GetTopStories {
  const GetTopStories(this._repository);

  final StoryRepository _repository;

  Future<Result<List<Story>>> call({required int page, required int pageSize}) {
    return _repository.getTopStories(page: page, pageSize: pageSize);
  }
}
