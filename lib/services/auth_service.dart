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
      print('📥 Response body: ${response.body}');

      final data = _client.parseResponse(response);
      print('📦 Parsed data: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        // Ensure user data is properly formatted
        final userData = data['user'] ?? {};
        print('👤 User data: $userData');
        
        // Convert user._id to string if it's an ObjectId
        if (userData['id'] != null && userData['id'] is! String) {
          userData['id'] = userData['id'].toString();
        }
        if (userData['_id'] != null) {
          userData['id'] = userData['_id'].toString();
        }
        
        // Save token and user data
        final token = data['token'] ?? '';
        if (token.isEmpty) {
          print('⚠️ Warning: Token is empty!');
        }
        
        await _client.setToken(token);
        await _client.setUserData(userData);

        print('✅ Sign in successful, token saved');
        print('👤 User role: ${userData['role']}');

        try {
          final signInResponse = SignInResponse.fromJson(data);
          return ApiResponse<SignInResponse>(
            success: true,
            message: data['message'],
            data: signInResponse,
          );
        } catch (parseError) {
          print('❌ Error parsing SignInResponse: $parseError');
          // Even if parsing fails, if we have token and user data, consider it successful
          if (token.isNotEmpty && userData.isNotEmpty) {
            return ApiResponse<SignInResponse>(
              success: true,
              message: data['message'] ?? 'Sign in successful',
              data: SignInResponse(
                token: token,
                user: User.fromJson(userData),
              ),
            );
          }
          throw parseError;
        }
      } else {
        print('❌ Sign in failed: ${data['message']}');
        return ApiResponse<SignInResponse>(
          success: false,
          message: data['message'] ?? 'Sign in failed',
          errors: data['errors'],
        );
      }
    } catch (e, stackTrace) {
      print('❌ Sign in error: $e');
      print('❌ Stack trace: $stackTrace');
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

