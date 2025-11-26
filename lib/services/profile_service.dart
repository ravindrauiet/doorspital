import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';

class ProfileService {
  final ApiClient _client = ApiClient();

  /// GET /api/profile/me
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      final response = await _client.get('/profile/me');
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: Map<String, dynamic>.from(data['data'] ?? {}),
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data['message'] ?? 'Failed to load profile',
        errors: data['errors'],
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// PUT /api/profile/me
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
      Map<String, dynamic> payload) async {
    try {
      final response = await _client.put('/profile/me', body: payload);
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data['message'],
          data: Map<String, dynamic>.from(data['data'] ?? {}),
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data['message'] ?? 'Failed to update profile',
        errors: data['errors'],
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}

