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

  static const _maxCommentsPerRequest = 25;
  static const _requestTimeout = Duration(seconds: 30);

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
    } catch (error) {
      return Error(
        Failure(
          message: 'Error fetching comment: $error',
          type: FailureType.unknown,
        ),
      );
    }
  }

  @override
  Future<Result<List<Comment>>> getComments(
    List<int> ids, {
    int depth = 0,
  }) async {
    try {
      if (ids.isEmpty) {
        return const Success(<Comment>[]);
      }

      // Limit concurrent requests to prevent overwhelming the API
      final limitedIds = ids.take(_maxCommentsPerRequest).toList();

      final results =
          await Future.wait(
            limitedIds.map((id) => getComment(id, depth: depth)),
            eagerError: false, // Continue even if some requests fail
          ).timeout(
            _requestTimeout,
            onTimeout: () => throw const ApiException(
              'Request timed out while loading comments.',
              type: FailureType.timeout,
            ),
          );

      final comments = results
          .whereType<Success<Comment>>()
          .map((result) => result.data)
          .toList();

      return Success(comments);
    } on ApiException catch (error) {
      return Error(error.toFailure());
    } catch (error) {
      return Error(
        Failure(
          message: 'Error fetching comments: $error',
          type: FailureType.unknown,
        ),
      );
    }
  }

  /// Clear all cached comments
  void clearCache() {
    _cache.clear();
  }

  /// Get cache size
  int getCacheSize() => _cache.length;
}
