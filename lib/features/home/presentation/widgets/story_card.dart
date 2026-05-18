import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/story_meta_item.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/story.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class StoryCard extends StatefulWidget {
  const StoryCard({required this.story, required this.index, super.key});

  final Story story;
  final int index;

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColors>()!;
    final story = widget.story;
    final isTrending = story.score >= 300 || widget.index < 5;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _pressed ? 0.985 : 1,
          child: Hero(
            tag: 'story-${story.id}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  sl<HapticService>().selection();
                  context.read<HomeBloc>().add(HomeStoryReadToggled(story.id));
                  context.pushNamed(
                    'story',
                    pathParameters: {'id': story.id.toString()},
                    extra: story.copyWith(isRead: true),
                  );
                },
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColors.surfaceRaised.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.84 : 0.92,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: appColors.subtleBorder.withValues(alpha: 0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: theme.brightness == Brightness.dark
                              ? 0.12
                              : 0.045,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppBadge(
                            icon: isTrending
                                ? Icons.trending_up_rounded
                                : Icons.auto_awesome_rounded,
                            label: isTrending
                                ? 'Trending'
                                : '#${widget.index + 1}',
                            color: isTrending
                                ? AppTheme.orange
                                : colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              story.url.domainLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          AppIconButton(
                            icon: story.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            tooltip: 'Bookmark',
                            isActive: story.isBookmarked,
                            size: 40,
                            onPressed: () {
                              sl<HapticService>().lightImpact();
                              context.read<HomeBloc>().add(
                                HomeBookmarkToggled(story.id),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        story.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          height: 1.18,
                          color: story.isRead
                              ? colors.onSurfaceVariant
                              : colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          StoryMetaItem(
                            icon: Icons.person_outline_rounded,
                            label: story.author,
                            compact: true,
                          ),
                          StoryMetaItem(
                            icon: Icons.bolt_rounded,
                            label: '${story.score} pts',
                            compact: true,
                          ),
                          StoryMetaItem(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: '${story.commentCount} comments',
                            compact: true,
                          ),
                          StoryMetaItem(
                            icon: Icons.schedule_rounded,
                            label: story.time.timeAgo,
                            compact: true,
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
      ),
    );
  }
}
