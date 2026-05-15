import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_comments.dart';
import 'detail_event.dart';
import 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc(this._getComments) : super(const DetailState()) {
    on<DetailStarted>(_onStarted);
    on<DetailRepliesToggled>(_onRepliesToggled);
  }

  final GetComments _getComments;

  Future<void> _onStarted(
    DetailStarted event,
    Emitter<DetailState> emit,
  ) async {
    if (event.commentIds.isEmpty) {
      emit(state.copyWith(status: DetailStatus.empty));
      return;
    }
    emit(state.copyWith(status: DetailStatus.loading));
    final result = await _getComments(event.commentIds);
    switch (result) {
      case Success<List<Comment>>(:final data):
        emit(
          state.copyWith(
            status: data.isEmpty ? DetailStatus.empty : DetailStatus.success,
            rootComments: data,
          ),
        );
      case Error<List<Comment>>(:final failure):
        emit(state.copyWith(status: DetailStatus.error, failure: failure));
    }
  }

  Future<void> _onRepliesToggled(
    DetailRepliesToggled event,
    Emitter<DetailState> emit,
  ) async {
    final isExpanded = state.expandedCommentIds.contains(event.commentId);
    final expanded = {...state.expandedCommentIds};
    if (isExpanded) {
      expanded.remove(event.commentId);
      emit(state.copyWith(expandedCommentIds: expanded));
      return;
    }

    expanded.add(event.commentId);
    if (state.repliesByParent.containsKey(event.commentId)) {
      emit(state.copyWith(expandedCommentIds: expanded));
      return;
    }

    emit(
      state.copyWith(
        expandedCommentIds: expanded,
        loadingReplyIds: {...state.loadingReplyIds, event.commentId},
      ),
    );
    final result = await _getComments(event.replyIds, depth: event.depth + 1);
    switch (result) {
      case Success<List<Comment>>(:final data):
        emit(
          state.copyWith(
            repliesByParent: {...state.repliesByParent, event.commentId: data},
            loadingReplyIds: {...state.loadingReplyIds}
              ..remove(event.commentId),
          ),
        );
      case Error<List<Comment>>():
        emit(
          state.copyWith(
            repliesByParent: {
              ...state.repliesByParent,
              event.commentId: const <Comment>[],
            },
            loadingReplyIds: {...state.loadingReplyIds}
              ..remove(event.commentId),
            failure: const Failure(message: 'Replies could not be loaded.'),
          ),
        );
    }
  }
}
