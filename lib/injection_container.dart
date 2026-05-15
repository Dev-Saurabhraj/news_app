import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'core/services/haptic_service.dart';
import 'features/detail/data/datasource/comment_remote_data_source.dart';
import 'features/detail/data/repositories/comment_repository_impl.dart';
import 'features/detail/domain/repositories/comment_repository.dart';
import 'features/detail/domain/usecases/get_comments.dart';
import 'features/detail/presentation/bloc/detail_bloc.dart';
import 'features/home/data/datasource/home_remote_data_source.dart';
import 'features/home/data/repositories/story_repository_impl.dart';
import 'features/home/domain/repositories/story_repository.dart';
import 'features/home/domain/usecases/get_story.dart';
import 'features/home/domain/usecases/get_top_stories.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton(ApiClient.new)
    ..registerLazySingleton(HapticService.new)
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<StoryRepository>(() => StoryRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetTopStories(sl()))
    ..registerLazySingleton(() => GetStory(sl()))
    ..registerFactory(() => HomeBloc(sl()))
    ..registerLazySingleton<CommentRemoteDataSource>(
      () => CommentRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetComments(sl()))
    ..registerFactory(() => DetailBloc(sl()));
}
