import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasource/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._remoteDataSource);

  final CommentRemoteDataSource _remoteDataSource;
  final Map<int, Comment> _cache = <int, Comment>{};

  @override
  Future<Result<Comment>> getComment(int id, {int depth = 0}) async {
    try {
      final cached = _cache[id];
      if (cached != null) return Success(cached.copyWith(depth: depth));
      final comment = await _remoteDataSource.getComment(id);
      if (comment == null || comment.text.isEmpty) {
        return const Error(
          Failure(
            message: 'This comment is unavailable.',
            type: FailureType.notFound,
          ),
        );
      }
      _cache[id] = comment;
      return Success(comment.copyWith(depth: depth));
    } on ApiException catch (error) {
      return Error(error.toFailure());
    } catch (_) {
      return const Error(
        Failure(message: 'Something went wrong while fetching comments.'),
      );
    }
  }

  @override
  Future<Result<List<Comment>>> getComments(
    List<int> ids, {
    int depth = 0,
  }) async {
    try {
      final results = await Future.wait(
        ids.take(25).map((id) => getComment(id, depth: depth)),
      );
      final comments = results
          .whereType<Success<Comment>>()
          .map((result) => result.data)
          .toList();
      return Success(comments);
    } on ApiException catch (error) {
      return Error(error.toFailure());
    } catch (_) {
      return const Error(
        Failure(message: 'Something went wrong while fetching comments.'),
      );
    }
  }
}
