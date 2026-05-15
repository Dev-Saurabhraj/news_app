import 'package:equatable/equatable.dart';

class Story extends Equatable {
  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.score,
    required this.time,
    required this.commentIds,
    this.url,
    this.text,
    this.isRead = false,
    this.isBookmarked = false,
  });

  final int id;
  final String title;
  final String author;
  final int score;
  final DateTime time;
  final List<int> commentIds;
  final String? url;
  final String? text;
  final bool isRead;
  final bool isBookmarked;

  int get commentCount => commentIds.length;

  Story copyWith({bool? isRead, bool? isBookmarked}) {
    return Story(
      id: id,
      title: title,
      author: author,
      score: score,
      time: time,
      commentIds: commentIds,
      url: url,
      text: text,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    score,
    time,
    commentIds,
    url,
    text,
    isRead,
    isBookmarked,
  ];
}
