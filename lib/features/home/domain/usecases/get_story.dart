import '../../../../core/utils/result.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

class GetStory {
  const GetStory(this._repository);

  final StoryRepository _repository;

  Future<Result<Story>> call(int id) => _repository.getStory(id);
}
