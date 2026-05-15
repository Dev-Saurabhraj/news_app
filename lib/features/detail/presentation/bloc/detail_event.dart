import 'package:equatable/equatable.dart';

sealed class DetailEvent extends Equatable {
  const DetailEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class DetailStarted extends DetailEvent {
  const DetailStarted({required this.storyId, required this.commentIds});
  final int storyId;
  final List<int> commentIds;

  @override
  List<Object?> get props => [storyId, commentIds];
}

class DetailRepliesToggled extends DetailEvent {
  const DetailRepliesToggled({
    required this.commentId,
    required this.replyIds,
    required this.depth,
  });
  final int commentId;
  final List<int> replyIds;
  final int depth;

  @override
  List<Object?> get props => [commentId, replyIds, depth];
}
