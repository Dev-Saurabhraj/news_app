import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<CommentModel?> getComment(int id);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  CommentRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<CommentModel?> getComment(int id) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiConstants.item(id),
      );

      // Check for null or deleted/dead items
      if (data.isEmpty) return null;
      if (data['deleted'] == true || data['dead'] == true) return null;
      if (data['type'] != 'comment') return null;

      // Validate required fields before parsing
      if (data['id'] == null) return null;

      return CommentModel.fromJson(data);
    } catch (error) {
      rethrow;
    }
  }
}
