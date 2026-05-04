import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/nurse_models.dart';

class NurseService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<PublicNurse>>> getPublicNurses({String? service}) async {
    try {
      final queryParams = <String, String>{};
      if (service != null && service.trim().isNotEmpty) {
        queryParams['service'] = service.trim();
      }

      final response = await _client.get(
        '/nurses/public',
        queryParams: queryParams,
        includeAuth: false,
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final items =
            (data['data'] as List<dynamic>? ?? const [])
                .map((item) => PublicNurse.fromJson(item as Map<String, dynamic>))
                .toList();
        return ApiResponse<List<PublicNurse>>(success: true, data: items);
      }

      return ApiResponse<List<PublicNurse>>(
        success: false,
        message: data['message'] ?? 'Failed to load nurses',
      );
    } catch (e) {
      return ApiResponse<List<PublicNurse>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
