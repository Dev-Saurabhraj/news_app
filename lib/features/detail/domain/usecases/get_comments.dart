import '../../../../core/utils/result.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetComments {
  const GetComments(this._repository);

  final CommentRepository _repository;

  Future<Result<List<Comment>>> call(List<int> ids, {int depth = 0}) {
    return _repository.getComments(ids, depth: depth);
  }
}
