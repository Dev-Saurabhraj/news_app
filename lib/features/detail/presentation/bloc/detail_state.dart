import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';

enum DetailStatus { initial, loading, success, empty, error }

class DetailState extends Equatable {
  const DetailState({
    this.status = DetailStatus.initial,
    this.rootComments = const <Comment>[],
    this.repliesByParent = const <int, List<Comment>>{},
    this.expandedCommentIds = const <int>{},
    this.loadingReplyIds = const <int>{},
    this.failure,
    this.readProgress = 0,
  });

  final DetailStatus status;
  final List<Comment> rootComments;
  final Map<int, List<Comment>> repliesByParent;
  final Set<int> expandedCommentIds;
  final Set<int> loadingReplyIds;
  final Failure? failure;
  final double readProgress;

  DetailState copyWith({
    DetailStatus? status,
    List<Comment>? rootComments,
    Map<int, List<Comment>>? repliesByParent,
    Set<int>? expandedCommentIds,
    Set<int>? loadingReplyIds,
    Failure? failure,
    double? readProgress,
  }) {
    return DetailState(
      status: status ?? this.status,
      rootComments: rootComments ?? this.rootComments,
      repliesByParent: repliesByParent ?? this.repliesByParent,
      expandedCommentIds: expandedCommentIds ?? this.expandedCommentIds,
      loadingReplyIds: loadingReplyIds ?? this.loadingReplyIds,
      failure: failure,
      readProgress: readProgress ?? this.readProgress,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rootComments,
    repliesByParent,
    expandedCommentIds,
    loadingReplyIds,
    failure,
    readProgress,
  ];
}
