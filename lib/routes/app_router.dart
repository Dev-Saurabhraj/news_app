import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/detail/presentation/pages/story_detail_page.dart';
import '../features/home/domain/entities/story.dart';
import '../features/home/presentation/pages/home_page.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: '/story/:id',
        name: 'story',
        pageBuilder: (context, state) {
          final story = state.extra as Story?;
          return CustomTransitionPage(
            child: StoryDetailPage(
              story: story,
              storyId: int.parse(state.pathParameters['id']!),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
          );
        },
      ),
    ],
  );
}
