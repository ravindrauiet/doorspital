import 'package:door/features/doorstep_service/models/doorstep_content_model.dart';
import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';

class DoorstepContentService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<DoorstepPageContent>> getDoorstepContent() async {
    try {
      final response = await _client.get(
        '/doorstep-content',
        includeAuth: false,
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<DoorstepPageContent>(
          success: true,
          data: DoorstepPageContent.fromJson(data['data'] ?? {}),
        );
      }

      return ApiResponse<DoorstepPageContent>(
        success: false,
        message: data['message'] ?? 'Failed to load doorstep content',
      );
    } catch (e) {
      return ApiResponse<DoorstepPageContent>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<DoorstepServiceContent>> getDoorstepServiceDetails(
    String serviceKey,
  ) async {
    try {
      final response = await _client.get(
        '/doorstep-content/$serviceKey',
        includeAuth: false,
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<DoorstepServiceContent>(
          success: true,
          data: DoorstepServiceContent.fromJson(data['data'] ?? {}),
        );
      }

      return ApiResponse<DoorstepServiceContent>(
        success: false,
        message: data['message'] ?? 'Failed to load service details',
      );
    } catch (e) {
      return ApiResponse<DoorstepServiceContent>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
