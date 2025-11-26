import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/auth_models.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<SignInResponse>> signIn(SignInRequest request) async {
    try {
      print('🔐 Attempting sign in for: ${request.email}');
      final response = await _client.post(
        '/auth/sign-in',
        body: request.toJson(),
        includeAuth: false,
      );

      print('✅ Received response with status: ${response.statusCode}');

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token and user data
        await _client.setToken(data['token'] ?? '');
        await _client.setUserData(data['user'] ?? {});

        print('✅ Sign in successful, token saved');

        return ApiResponse<SignInResponse>(
          success: true,
          message: data['message'],
          data: SignInResponse.fromJson(data),
        );
      } else {
        print('❌ Sign in failed: ${data['message']}');
        return ApiResponse<SignInResponse>(
          success: false,
          message: data['message'] ?? 'Sign in failed',
          errors: data['errors'],
        );
      }
    } catch (e) {
      print('❌ Sign in error: $e');
      return ApiResponse<SignInResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signUp(
      SignUpRequest request) async {
    try {
      final response = await _client.post(
        '/auth/sign-up',
        body: request.toJson(),
        includeAuth: false,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data['message'],
          data: data['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: data['message'] ?? 'Sign up failed',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _client.post('/auth/sign-out');
    } catch (e) {
      // Ignore errors on sign out
    } finally {
      await _client.clearToken();
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _client.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<User?> getCurrentUser() async {
    final userData = await _client.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }
}

