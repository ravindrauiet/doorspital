import 'dart:io';
import 'package:door/services/api_client.dart';
import 'package:http/http.dart' as http;

/// Utility class to test API connection
class ConnectionTest {
  static final ApiClient _client = ApiClient();

  /// Test if the API server is reachable
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final baseUrl = _client.baseUrl;
      print('🧪 Testing connection to: $baseUrl');

      // Try to reach the base URL
      final uri = Uri.parse(baseUrl.replaceAll('/api', ''));
      print('🧪 Testing: $uri');

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Connection timeout - server not reachable');
            },
          );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Server is reachable',
        'baseUrl': baseUrl,
      };
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'SocketException',
        'message':
            'Unable to reach ${_client.baseUrl}. '
            'Please ensure the Render deployment is running and that your device has network connectivity.',
        'details': e.message,
        'baseUrl': _client.baseUrl,
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'error': 'ClientException',
        'message': 'Network request failed',
        'details': e.message,
        'baseUrl': _client.baseUrl,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unknown',
        'message': 'Connection test failed',
        'details': e.toString(),
        'baseUrl': _client.baseUrl,
      };
    }
  }

  /// Test the sign-in endpoint specifically
  static Future<Map<String, dynamic>> testSignInEndpoint() async {
    try {
      final baseUrl = _client.baseUrl;
      final testUri = Uri.parse('$baseUrl/auth/sign-in');

      print('🧪 Testing sign-in endpoint: $testUri');

      final response = await http
          .post(
            testUri,
            headers: {'Content-Type': 'application/json'},
            body: '{"email":"test@example.com","password":"test"}',
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      return {
        'success': response.statusCode < 500,
        'statusCode': response.statusCode,
        'message': response.statusCode == 401
            ? 'Endpoint is reachable (401 is expected for invalid credentials)'
            : 'Endpoint responded',
        'baseUrl': baseUrl,
        'endpoint': testUri.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.runtimeType.toString(),
        'message': 'Cannot reach sign-in endpoint',
        'details': e.toString(),
        'baseUrl': _client.baseUrl,
      };
    }
  }
}
