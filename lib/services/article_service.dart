import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/article_model.dart';

class ArticleService {
  final ApiClient _client = ApiClient();

  // GET /api/health-articles
  Future<ApiResponse<List<Article>>> getArticles() async {
    try {
      final response = await _client.get(
        '/health-articles',
        includeAuth: false,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
         final articles = (data['data'] as List<dynamic>?)
                ?.map((item) => Article.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        return ApiResponse<List<Article>>(
          success: true,
          data: articles,
        );
      } else {
        return ApiResponse<List<Article>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch articles',
        );
      }
    } catch (e) {
      return ApiResponse<List<Article>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
