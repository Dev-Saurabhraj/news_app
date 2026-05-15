import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.time,
    required this.replyIds,
    required this.parent,
    this.depth = 0,
  });

  final int id;
  final String author;
  final String text;
  final DateTime time;
  final List<int> replyIds;
  final int parent;
  final int depth;

  int get replyCount => replyIds.length;

  Comment copyWith({int? depth}) {
    return Comment(
      id: id,
      author: author,
      text: text,
      time: time,
      replyIds: replyIds,
      parent: parent,
      depth: depth ?? this.depth,
    );
  }

  @override
  List<Object?> get props => [id, author, text, time, replyIds, parent, depth];
}
