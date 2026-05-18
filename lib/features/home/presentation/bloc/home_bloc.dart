import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/get_top_stories.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._getTopStories) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeNextPageRequested>(_onNextPageRequested);
    on<HomeSearchChanged>(_onSearchChanged);
    on<HomeSearchCleared>(_onSearchCleared);
    on<HomeStoryReadToggled>(_onReadToggled);
    on<HomeBookmarkToggled>(_onBookmarkToggled);
  }

  static const _pageSize = 18;
  final GetTopStories _getTopStories;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (state.stories.isNotEmpty) {
      return;
    }
    emit(state.copyWith(status: HomeStatus.loading));
    await _loadPage(emit, page: 0, replace: true);
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomeStatus.refreshing,
        isPaginating: false,
        page: 0,
        hasReachedEnd: false,
      ),
    );
    await _loadPage(emit, page: 0, replace: true);
  }

  Future<void> _onNextPageRequested(
    HomeNextPageRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isPaginating ||
        state.hasReachedEnd ||
        state.status != HomeStatus.success) {
      return;
    }
    emit(state.copyWith(isPaginating: true));
    await _loadPage(emit, page: state.page + 1, replace: false);
  }

  Future<void> _loadPage(
    Emitter<HomeState> emit, {
    required int page,
    required bool replace,
  }) async {
    final result = await _getTopStories(page: page, pageSize: _pageSize);
    switch (result) {
      case Success<List<Story>>(:final data):
        final stories = replace
            ? _applyBookmarks(data)
            : <Story>[...state.stories, ..._applyBookmarks(data)];
        emit(
          state.copyWith(
            status: stories.isEmpty ? HomeStatus.empty : HomeStatus.success,
            stories: stories,
            page: page,
            hasReachedEnd: data.length < _pageSize,
            isPaginating: false,
          ),
        );
      case Error<List<Story>>(:final failure):
        emit(
          state.copyWith(
            status: HomeStatus.error,
            failure: failure,
            isPaginating: false,
          ),
        );
    }
  }

  void _onSearchChanged(HomeSearchChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSearchCleared(HomeSearchCleared event, Emitter<HomeState> emit) {
    emit(state.copyWith(searchQuery: ''));
  }

  void _onReadToggled(HomeStoryReadToggled event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        stories: _mapStory(
          event.storyId,
          (story) => story.copyWith(isRead: true),
        ),
      ),
    );
  }

  void _onBookmarkToggled(HomeBookmarkToggled event, Emitter<HomeState> emit) {
    final bookmarkedIds = {...state.bookmarkedStoryIds};
    final isBookmarked = bookmarkedIds.contains(event.storyId);
    if (isBookmarked) {
      bookmarkedIds.remove(event.storyId);
    } else {
      bookmarkedIds.add(event.storyId);
    }

    emit(
      state.copyWith(
        bookmarkedStoryIds: bookmarkedIds,
        stories: _mapStory(
          event.storyId,
          (story) => story.copyWith(isBookmarked: !isBookmarked),
        ),
      ),
    );
  }

  List<Story> _applyBookmarks(List<Story> stories) {
    if (state.bookmarkedStoryIds.isEmpty) {
      return stories;
    }

    return stories
        .map(
          (story) => story.copyWith(
            isBookmarked: state.bookmarkedStoryIds.contains(story.id),
          ),
        )
        .toList(growable: false);
  }

  List<Story> _mapStory(int id, Story Function(Story story) transform) {
    return state.stories
        .map((story) => story.id == id ? transform(story) : story)
        .toList(growable: false);
  }
}
