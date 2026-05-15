import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/story.dart';

enum HomeStatus { initial, loading, refreshing, success, empty, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.stories = const <Story>[],
    this.failure,
    this.page = 0,
    this.hasReachedEnd = false,
    this.isPaginating = false,
    this.searchQuery = '',
  });

  final HomeStatus status;
  final List<Story> stories;
  final Failure? failure;
  final int page;
  final bool hasReachedEnd;
  final bool isPaginating;
  final String searchQuery;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  List<Story> get visibleStories {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return stories;

    return stories
        .where((story) {
          final haystack = '${story.title} ${story.author} ${story.url ?? ''}'
              .toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  HomeState copyWith({
    HomeStatus? status,
    List<Story>? stories,
    Failure? failure,
    int? page,
    bool? hasReachedEnd,
    bool? isPaginating,
    String? searchQuery,
  }) {
    return HomeState(
      status: status ?? this.status,
      stories: stories ?? this.stories,
      failure: failure,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isPaginating: isPaginating ?? this.isPaginating,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stories,
    failure,
    page,
    hasReachedEnd,
    isPaginating,
    searchQuery,
  ];
}
