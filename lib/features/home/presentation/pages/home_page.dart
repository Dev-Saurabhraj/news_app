import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/failure_view.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/story_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter < 620) {
      context.read<HomeBloc>().add(const HomeNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_scrollController.hasClients) {
            return;
          }
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
          );
        },
        child: const Icon(Icons.keyboard_arrow_up_rounded),
      ),
      body: RefreshIndicator.adaptive(
        color: colors.primary,
        onRefresh: () async {
          context.read<HomeBloc>().add(const HomeRefreshed());
          await context.read<HomeBloc>().stream.firstWhere(
            (state) => state.status != HomeStatus.refreshing,
          );
        },
        child: CustomScrollView(
          controller: _scrollController,
          cacheExtent: 900,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar.large(
              pinned: true,
              stretch: true,
              expandedHeight: _isSearchOpen ? 214 : 176,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              foregroundColor: colors.onSurface,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Signal HN',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: colors.onSurface),
              ),
              actions: [
                BlocSelector<HomeBloc, HomeState, String>(
                  selector: (state) => state.searchQuery,
                  builder: (context, query) {
                    return AppIconButton(
                      icon: _isSearchOpen
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      tooltip: _isSearchOpen ? 'Close search' : 'Search',
                      isActive: query.isNotEmpty,
                      onPressed: () {
                        if (_isSearchOpen) {
                          _searchController.clear();
                          _searchFocusNode.unfocus();
                          context.read<HomeBloc>().add(
                            const HomeSearchCleared(),
                          );
                          setState(() => _isSearchOpen = false);
                          return;
                        }

                        setState(() => _isSearchOpen = true);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _searchFocusNode.requestFocus();
                        });
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: Icons.brightness_6_rounded,
                  tooltip: 'Toggle theme',
                  onPressed: () => context.read<ThemeCubit>().toggleTheme(
                    MediaQuery.platformBrightnessOf(context),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final topPadding = MediaQuery.paddingOf(context).top;
                  final toolbarHeight = kToolbarHeight + topPadding;
                  final expandedHeight = _isSearchOpen ? 214.0 : 176.0;
                  final progress =
                      ((constraints.maxHeight - toolbarHeight) /
                              (expandedHeight - toolbarHeight))
                          .clamp(0.0, 1.0);

                  return ClipRect(
                    child: Opacity(
                      opacity: progress,
                      child: IgnorePointer(
                        ignoring: progress < 0.95,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            18,
                            _isSearchOpen ? 86 : 90,
                            18,
                            18,
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeOutCubic,
                              child: _isSearchOpen
                                  ? _SearchHeader(
                                      key: const ValueKey('search-header'),
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      onChanged: (query) => context
                                          .read<HomeBloc>()
                                          .add(HomeSearchChanged(query)),
                                      onSubmitted: (_) =>
                                          _searchFocusNode.unfocus(),
                                    )
                                  : Text(
                                      _greeting(),
                                      key: const ValueKey('greeting-header'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            height: 1.05,
                                            color: colors.onSurface,
                                          ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.stories != current.stories ||
                  previous.isPaginating != current.isPaginating ||
                  previous.searchQuery != current.searchQuery,
              builder: (context, state) {
                if (state.status == HomeStatus.loading ||
                    state.status == HomeStatus.initial) {
                  return const HomeSkeleton();
                }
                if (state.status == HomeStatus.error && state.stories.isEmpty) {
                  return SliverFillRemaining(
                    child: FailureView(
                      failure: state.failure!,
                      onRetry: () =>
                          context.read<HomeBloc>().add(const HomeStarted()),
                    ),
                  );
                }
                if (state.status == HomeStatus.empty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No stories found.')),
                  );
                }
                final stories = state.visibleStories;
                if (state.isSearching && stories.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoSearchResults(query: state.searchQuery),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
                  sliver: SliverList.separated(
                    itemCount: stories.length + (state.isPaginating ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index >= stories.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return StoryCard(story: stories[index], index: index);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning briefing for curious builders.';
    if (hour < 18) return 'Sharp stories for your afternoon.';
    return 'A focused read for tonight.';
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find signal fast',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        _SearchField(
          key: const ValueKey('search-field'),
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: 'Search stories, authors, domains',
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.onSurfaceVariant,
          ),
          filled: true,
          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.72),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.manage_search_rounded, size: 42, color: colors.primary),
            const SizedBox(height: 14),
            Text(
              'No matches for "$query"',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a title keyword, author name, or source domain from the loaded feed.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
