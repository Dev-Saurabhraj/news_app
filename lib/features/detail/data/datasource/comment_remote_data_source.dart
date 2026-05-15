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
    final data = await _client.get<Map<String, dynamic>>(ApiConstants.item(id));
    if (data['deleted'] == true ||
        data['dead'] == true ||
        data['type'] != 'comment') {
      return null;
    }
    return CommentModel.fromJson(data);
  }
}
