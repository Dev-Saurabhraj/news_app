import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasource/home_remote_data_source.dart';

class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;
  List<int>? _cachedIds;
  final Map<int, Story> _storyCache = <int, Story>{};

  static const _requestTimeout = Duration(seconds: 30);

  @override
  Future<Result<List<Story>>> getTopStories({
    required int page,
    required int pageSize,
  }) async {
    try {
      _cachedIds ??= await _remoteDataSource.getTopStoryIds();

      if (_cachedIds == null || _cachedIds!.isEmpty) {
        return const Error(
          Failure(message: 'No stories available.', type: FailureType.empty),
        );
      }

      final start = page * pageSize;
      if (start >= _cachedIds!.length) return const Success(<Story>[]);

      final ids = _cachedIds!.skip(start).take(pageSize).toList();

      // Use timeout to prevent hanging on large concurrent requests
      final stories = await Future.wait(ids.map(getStory), eagerError: true)
          .timeout(
            _requestTimeout,
            onTimeout: () => throw const ApiException(
              'Request timed out while loading stories.',
              type: FailureType.timeout,
            ),
          );

      final successful = stories
          .whereType<Success<Story>>()
          .map((result) => result.data)
          .toList();

      if (successful.isEmpty) {
        return const Error(
          Failure(
            message: 'No readable stories were returned.',
            type: FailureType.empty,
          ),
        );
      }
      return Success(successful);
    } on ApiException catch (error) {
      return Error(error.toFailure());
    } catch (error) {
      return Error(
        Failure(
          message: 'Something went wrong while fetching top stories: $error',
          type: FailureType.unknown,
        ),
      );
    }
  }

  @override
  Future<Result<Story>> getStory(int id) async {
    try {
      final cached = _storyCache[id];
      if (cached != null) return Success(cached);

      final story = await _remoteDataSource.getStory(id);
      if (story == null) {
        return const Error(
          Failure(
            message: 'This story is no longer available.',
            type: FailureType.notFound,
          ),
        );
      }
      _storyCache[id] = story;
      return Success(story);
    } on ApiException catch (error) {
      return Error(error.toFailure());
    } catch (error) {
      return Error(
        Failure(
          message: 'Something went wrong while fetching the story: $error',
          type: FailureType.unknown,
        ),
      );
    }
  }

  /// Clear all cached stories
  void clearStoryCache() {
    _storyCache.clear();
  }

  /// Clear cached story IDs (useful when refreshing the feed)
  void clearIdCache() {
    _cachedIds = null;
  }

  /// Clear both caches
  void clearAllCaches() {
    clearStoryCache();
    clearIdCache();
  }
}
