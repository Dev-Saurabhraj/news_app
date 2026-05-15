import '../../../../core/extensions/date_time_extensions.dart';
import '../../domain/entities/story.dart';

class StoryModel extends Story {
  const StoryModel({
    required super.id,
    required super.title,
    required super.author,
    required super.score,
    required super.time,
    required super.commentIds,
    super.url,
    super.text,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? 'Untitled story',
      author: (json['by'] as String?) ?? 'anonymous',
      score: (json['score'] as int?) ?? 0,
      time: ((json['time'] as int?) ?? 0).fromUnixSeconds,
      commentIds: List<int>.from(
        (json['kids'] as List<dynamic>?) ?? const <dynamic>[],
      ),
      url: json['url'] as String?,
      text: json['text'] as String?,
    );
  }
}
