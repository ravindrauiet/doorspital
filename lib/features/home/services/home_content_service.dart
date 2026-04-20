import 'package:door/features/home/models/home_content_model.dart';
import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';

class HomeContentService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<HomeContent>> getHomeContent() async {
    try {
      final response = await _client.get('/home-content', includeAuth: false);
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<HomeContent>(
          success: true,
          data: HomeContent.fromJson(data['data'] ?? {}),
        );
      }

      return ApiResponse<HomeContent>(
        success: false,
        message: data['message'] ?? 'Failed to load home content',
      );
    } catch (e) {
      return ApiResponse<HomeContent>(success: false, message: e.toString());
    }
  }
}
