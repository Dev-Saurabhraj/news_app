# Signal HN - Hacker News Reader

A production-style Hacker News reader built with Flutter, BLoC, Dio, GoRouter, GetIt, and feature-first clean architecture.

This project is designed to feel closer to a real startup mobile product than a basic assignment app. It includes a polished home feed, story detail screen, lazy nested comments, theme support, shimmer loading states, typed error handling, dependency injection, and a scalable folder structure.

## Features

- Top Hacker News stories feed
- Story detail screen with article actions
- Recursive nested comment threads
- Lazy loading replies on expand
- Search across loaded stories by title, author, and domain
- Pull to refresh
- Pagination/infinite scrolling
- Bookmark and read/unread UI state
- Light and dark themes
- Shimmer skeleton loading
- Friendly error and empty states
- HTML comment rendering with `flutter_html`
- External article and Hacker News discussion links
- Share action
- Responsive, sliver-based UI
- Scroll-performance optimizations

## Tech Stack

- Flutter
- BLoC / `flutter_bloc`
- Dio
- GoRouter
- GetIt
- Equatable
- Google Fonts
- Shimmer
- flutter_html
- url_launcher
- share_plus
- intl
- flutter_animate

## API

The app uses the official Hacker News Firebase API:

```text
Top stories:
https://hacker-news.firebaseio.com/v0/topstories.json

Item detail:
https://hacker-news.firebaseio.com/v0/item/<id>.json
```

Stories and comments both come from the item detail endpoint. Hacker News represents nesting through IDs:

```text
Story
  kids: [commentId, commentId, commentId]

Comment
  kids: [replyId, replyId, replyId]
```

The app maps `kids` on a story to `commentIds`, and maps `kids` on a comment to `replyIds`.

## Architecture

The codebase uses feature-first clean architecture:

```text
lib/
  core/
    constants/
    errors/
    network/
    services/
    utils/
    theme/
    widgets/
    extensions/
    animations/

  features/
    home/
      data/
        datasource/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/

    detail/
      data/
        datasource/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/

  routes/
  app.dart
  injection_container.dart
  main.dart
```

### Layer Responsibilities

`data`

Handles API calls, DTO/model parsing, repository implementations, and local in-memory caching.

`domain`

Contains entities, abstract repository contracts, and use cases. This layer is independent of Flutter UI.

`presentation`

Contains BLoCs, pages, and widgets. UI state is driven by immutable BLoC state instead of business logic inside widgets.

`core`

Shared infrastructure used across features: networking, errors, result wrapper, theme, reusable widgets, extensions, and services.

## Important Files

- `lib/main.dart` - app entry point
- `lib/app.dart` - root `MaterialApp.router` and global providers
- `lib/injection_container.dart` - GetIt dependency injection setup
- `lib/routes/app_router.dart` - GoRouter routes
- `lib/core/network/api_client.dart` - Dio setup, logging, timeout, retry
- `lib/core/utils/result.dart` - typed success/error wrapper
- `lib/core/errors/` - API exception and failure mapping
- `lib/core/theme/app_theme.dart` - light/dark app themes
- `lib/features/home/presentation/bloc/` - home feed state management
- `lib/features/detail/presentation/bloc/` - detail/comment state management
- `lib/features/detail/presentation/widgets/comment_thread.dart` - recursive comment UI

## State Management

The app uses BLoC for feature state.

### Home BLoC

Responsible for:

- Initial loading
- Refreshing
- Pagination
- Search query
- Read state
- Bookmark state
- Empty/error/success states

Home state stores all loaded stories and exposes `visibleStories`, which filters the loaded feed when search is active.

### Detail BLoC

Responsible for:

- Loading root comments
- Expanding/collapsing replies
- Lazy loading nested replies
- Tracking loading reply IDs
- Storing replies by parent comment ID

Replies are stored like this:

```dart
Map<int, List<Comment>> repliesByParent;
```

Example:

```text
repliesByParent[100] = [Comment 201, Comment 202]
repliesByParent[201] = [Comment 301]
```

This avoids building one huge nested object tree and keeps loading incremental.

## Recursive Comment System

The comment system is lazy and recursive.

1. The story detail page receives the story's root `commentIds`.
2. `DetailBloc` fetches the first level of comments.
3. Each `Comment` contains its own `replyIds`.
4. When the user taps "View replies", the bloc fetches only those reply IDs.
5. `CommentThread` renders replies by recursively creating more `CommentThread` widgets.

This design supports deep nested threads without downloading everything upfront.

## Error Handling

Networking errors are mapped into user-friendly failures:

- Network errors
- Timeout errors
- Server errors
- Not found
- Empty data
- Unknown errors

The UI consumes these failures through reusable error widgets and retry actions.

## Performance Notes

Several choices are made to keep scrolling smooth:

- Sliver-based screens
- Lazy list rendering
- Paginated story loading
- Lazy comment reply loading
- `RepaintBoundary` around heavy list items
- Avoiding expensive intrinsic layout in comment trees
- Reduced shadow blur on cards
- Detail reading progress uses `ValueNotifier` instead of rebuilding the whole page
- Scroll controller guards to prevent crashes during fast gestures

## Getting Started

### Prerequisites

- Flutter latest stable
- Dart SDK compatible with the project SDK constraint
- Android Studio, VS Code, or another Flutter-capable IDE

Check your Flutter installation:

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run on a web server:

```bash
flutter run -d web-server
```

## Quality Checks

Format:

```bash
dart format lib test
```

Analyze:

```bash
flutter analyze
```

Test:

```bash
flutter test
```

Build web:

```bash
flutter build web
```

## Current Limitations

- Search filters only stories already loaded into the feed.
- Bookmark/read state is currently in-memory only.
- The direct detail route expects a story object from home navigation.
- Comment replies are capped in repository fetching to keep large threads responsive.

These are intentional tradeoffs for a clean assignment/demo build and can be extended with persistence, background prefetching, and offline caching.

## Possible Improvements

- Persist bookmarks and read status with HydratedBloc or local storage
- Add offline story/comment cache
- Add full remote search or Algolia HN search
- Add unit tests for repositories and BLoCs
- Add golden tests for theme/UI states
- Add deep-link detail loading by story ID
- Add comment sorting and collapse-all controls

## Project Goal

The goal of this project is to demonstrate:

- Clean Architecture
- Scalable feature-first structure
- Proper BLoC state management
- Typed error handling
- Premium Flutter UI implementation
- Recursive nested comment handling
- Maintainable production-oriented code
