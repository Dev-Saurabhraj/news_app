import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/failure_view.dart';
import '../../../../core/widgets/story_meta_item.dart';
import '../../../../injection_container.dart';
import '../../../home/domain/entities/story.dart';
import '../../../home/domain/usecases/get_story.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../bloc/detail_bloc.dart';
import '../bloc/detail_event.dart';
import '../bloc/detail_state.dart';
import '../widgets/comment_skeleton.dart';
import '../widgets/comment_thread.dart';

class StoryDetailPage extends StatefulWidget {
  const StoryDetailPage({required this.storyId, super.key, this.story});

  final int storyId;
  final Story? story;

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  final _scrollController = ScrollController();
  final _progress = ValueNotifier<double>(0);
  Future<Result<Story>>? _storyFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
    _storyFuture = widget.story == null ? sl<GetStory>()(widget.storyId) : null;
  }

  @override
  void didUpdateWidget(covariant StoryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.story == null && widget.storyId != oldWidget.storyId) {
      _storyFuture = sl<GetStory>()(widget.storyId);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateProgress)
      ..dispose();
    _progress.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent <= 0) {
      return;
    }
    final nextProgress =
        (_scrollController.offset / _scrollController.position.maxScrollExtent)
            .clamp(0.0, 1.0);
    if ((nextProgress - _progress.value).abs() > 0.01) {
      _progress.value = nextProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    if (story == null) {
      return _StoryLoader(
        future: _storyFuture!,
        onLoaded: (story) => _buildStoryScaffold(context, story),
        onRetry: () => setState(() {
          _storyFuture = sl<GetStory>()(widget.storyId);
        }),
      );
    }

    return _buildStoryScaffold(context, story);
  }

  Widget _buildStoryScaffold(BuildContext context, Story story) {
    return BlocProvider(
      create: (_) => sl<DetailBloc>()
        ..add(DetailStarted(storyId: story.id, commentIds: story.commentIds)),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              cacheExtent: 900,
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  expandedHeight: 320,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  surfaceTintColor: Colors.transparent,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AppIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  actions: [
                    AppIconButton(
                      icon: Icons.ios_share_rounded,
                      tooltip: 'Share',
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(
                          text:
                              story.url ??
                              'https://news.ycombinator.com/item?id=${story.id}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocSelector<HomeBloc, HomeState, bool>(
                      selector: (state) =>
                          state.bookmarkedStoryIds.contains(story.id) ||
                          state.stories.any(
                            (item) => item.id == story.id && item.isBookmarked,
                          ),
                      builder: (context, isBookmarked) {
                        return AppIconButton(
                          icon: isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          tooltip: isBookmarked ? 'Saved' : 'Save',
                          isActive: isBookmarked,
                          onPressed: () {
                            sl<HapticService>().lightImpact();
                            context.read<HomeBloc>().add(
                              HomeBookmarkToggled(story.id),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'story-${story.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 108, 20, 28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.18),
                                Theme.of(context).colorScheme.surface,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                story.url.domainLabel,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                story.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      height: 1.08,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AppBadge(
                                    icon: Icons.person_outline_rounded,
                                    label: story.author,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  AppBadge(
                                    icon: Icons.bolt_rounded,
                                    label: '${story.score} points',
                                    color: AppTheme.orange,
                                  ),
                                  AppBadge(
                                    icon: Icons.chat_bubble_outline_rounded,
                                    label: '${story.commentCount} comments',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),
                                  AppBadge(
                                    icon: Icons.schedule_rounded,
                                    label: story.time.timeAgo,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: story.url == null
                                    ? null
                                    : () => launchUrl(
                                        Uri.parse(story.url!),
                                        mode: LaunchMode.externalApplication,
                                      ),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('Open article'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                              tooltip: 'HN discussion',
                              onPressed: () => launchUrl(
                                Uri.parse(
                                  'https://news.ycombinator.com/item?id=${story.id}',
                                ),
                                mode: LaunchMode.externalApplication,
                              ),
                              icon: const Icon(Icons.forum_rounded),
                            ),
                          ],
                        ),
                        if ((story.text ?? '').isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Html(data: story.text),
                        ],
                        const SizedBox(height: 28),
                        Text(
                          'Discussion',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        StoryMetaItem(
                          icon: Icons.forum_rounded,
                          label:
                              '${story.commentCount} comments from Hacker News',
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<DetailBloc, DetailState>(
                  builder: (context, state) {
                    if (state.status == DetailStatus.loading ||
                        state.status == DetailStatus.initial) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.builder(
                          itemCount: 8,
                          itemBuilder: (context, index) =>
                              const CommentSkeleton(),
                        ),
                      );
                    }
                    if (state.status == DetailStatus.error) {
                      return SliverFillRemaining(
                        child: FailureView(
                          failure: state.failure!,
                          title: 'Could not load discussion',
                          onRetry: () => context.read<DetailBloc>().add(
                            DetailStarted(
                              storyId: story.id,
                              commentIds: story.commentIds,
                            ),
                          ),
                        ),
                      );
                    }
                    if (state.status == DetailStatus.empty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text('No comments yet.')),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 72),
                      sliver: SliverList.builder(
                        itemCount: state.rootComments.length,
                        itemBuilder: (context, index) =>
                            CommentThread(comment: state.rootComments[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: ValueListenableBuilder<double>(
                  valueListenable: _progress,
                  builder: (context, progress, child) {
                    return LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: Colors.transparent,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryLoader extends StatelessWidget {
  const _StoryLoader({
    required this.future,
    required this.onLoaded,
    required this.onRetry,
  });

  final Future<Result<Story>> future;
  final Widget Function(Story story) onLoaded;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Story>>(
      future: future,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result is Success<Story>) {
          return onLoaded(result.data);
        }
        if (result is Error<Story>) {
          return Scaffold(
            appBar: AppBar(),
            body: FailureView(
              failure: result.failure,
              title: 'Could not load this story',
              onRetry: onRetry,
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        );
      },
    );
  }
}
