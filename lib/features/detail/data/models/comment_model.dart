import '../../../../core/extensions/date_time_extensions.dart';
import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.author,
    required super.text,
    required super.time,
    required super.replyIds,
    required super.parent,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      author: (json['by'] as String?) ?? 'anonymous',
      text: (json['text'] as String?) ?? '',
      time: ((json['time'] as int?) ?? 0).fromUnixSeconds,
      replyIds: List<int>.from(
        (json['kids'] as List<dynamic>?) ?? const <dynamic>[],
      ),
      parent: (json['parent'] as int?) ?? 0,
    );
  }
}
