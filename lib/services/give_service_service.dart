import 'package:door/services/api_client.dart';

class GiveServiceService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> submitRequest(String name, String mobileNumber, String profession) async {
    try {
      final response = await _apiClient.post(
        '/give-service',
        body: {
          'name': name,
          'mobileNumber': mobileNumber,
          'profession': profession,
        },
        includeAuth: false, // We don't necessarily need auth for this
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('GivenService request failed: $e');
      return false;
    }
  }
}
