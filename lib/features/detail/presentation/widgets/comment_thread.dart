import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/comment.dart';
import '../bloc/detail_bloc.dart';
import '../bloc/detail_event.dart';
import '../bloc/detail_state.dart';
import 'comment_skeleton.dart';

class CommentThread extends StatelessWidget {
  const CommentThread({required this.comment, super.key});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DetailBloc, DetailState, _CommentViewState>(
      selector: (state) => _CommentViewState(
        replies: state.repliesByParent[comment.id] ?? const <Comment>[],
        isExpanded: state.expandedCommentIds.contains(comment.id),
        isLoading: state.loadingReplyIds.contains(comment.id),
      ),
      builder: (context, viewState) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final maxIndentDepth = comment.depth.clamp(0, 6);
        final authorInitial = comment.author.trim().characters.firstOrNull;
        return Padding(
          padding: EdgeInsets.only(left: maxIndentDepth * 16.0, bottom: 14),
          child: RepaintBoundary(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: comment.depth == 0
                        ? AppTheme.orange.withValues(alpha: 0.7)
                        : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: colors.primary.withValues(
                              alpha: 0.13,
                            ),
                            child: Text(
                              (authorInitial ?? '?').toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              comment.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comment.time.timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Html(
                        data: comment.text,
                        onLinkTap: (url, attributes, element) {
                          final uri = Uri.tryParse(url ?? '');
                          if (uri != null) {
                            launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        style: {
                          'body': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: colors.onSurface,
                            fontSize: FontSize(14.5),
                            lineHeight: const LineHeight(1.46),
                          ),
                          'p': Style(margin: Margins.only(bottom: 8)),
                          'a': Style(
                            color: colors.primary,
                            textDecoration: TextDecoration.none,
                          ),
                          'pre': Style(
                            backgroundColor: colors.surfaceContainerHighest,
                            padding: HtmlPaddings.all(10),
                            margin: Margins.only(top: 6, bottom: 6),
                          ),
                        },
                      ),
                      if (comment.replyCount > 0) ...[
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => context.read<DetailBloc>().add(
                            DetailRepliesToggled(
                              commentId: comment.id,
                              replyIds: comment.replyIds,
                              depth: comment.depth,
                            ),
                          ),
                          icon: AnimatedRotation(
                            turns: viewState.isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                            ),
                          ),
                          label: Text(
                            '${viewState.isExpanded ? 'Hide' : 'View'} ${comment.replyCount} replies',
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          child: viewState.isExpanded
                              ? Column(
                                  children: [
                                    if (viewState.isLoading)
                                      const CommentSkeleton(compact: true),
                                    for (final reply in viewState.replies)
                                      CommentThread(comment: reply),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentViewState {
  const _CommentViewState({
    required this.replies,
    required this.isExpanded,
    required this.isLoading,
  });

  final List<Comment> replies;
  final bool isExpanded;
  final bool isLoading;
}
