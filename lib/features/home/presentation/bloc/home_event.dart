import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

class HomeNextPageRequested extends HomeEvent {
  const HomeNextPageRequested();
}

class HomeSearchChanged extends HomeEvent {
  const HomeSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class HomeSearchCleared extends HomeEvent {
  const HomeSearchCleared();
}

class HomeStoryReadToggled extends HomeEvent {
  const HomeStoryReadToggled(this.storyId);
  final int storyId;

  @override
  List<Object?> get props => [storyId];
}

class HomeBookmarkToggled extends HomeEvent {
  const HomeBookmarkToggled(this.storyId);
  final int storyId;

  @override
  List<Object?> get props => [storyId];
}
