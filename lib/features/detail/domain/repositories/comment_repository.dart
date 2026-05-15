import '../../../../core/utils/result.dart';
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<Result<List<Comment>>> getComments(List<int> ids, {int depth = 0});
  Future<Result<Comment>> getComment(int id, {int depth = 0});
}
