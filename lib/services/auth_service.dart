import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/auth_models.dart';
import 'package:door/services/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: <String>['email', 'profile']);

  firebase_auth.FirebaseAuth get _firebaseAuth =>
      firebase_auth.FirebaseAuth.instance;

  Future<ApiResponse<SignInResponse>> _storeSuccessfulSignIn(
    Map<String, dynamic> data, {
    Map<String, dynamic>? fallbackUser,
  }) async {
    final token = (data['token'] ?? '').toString();
    final responseUser = <String, dynamic>{};

    final rawUser = data['user'];
    if (rawUser is Map) {
      responseUser.addAll(Map<String, dynamic>.from(rawUser));
    }
    if (responseUser.isEmpty && fallbackUser != null) {
      responseUser.addAll(fallbackUser);
    }

    if (responseUser['id'] == null && responseUser['_id'] != null) {
      responseUser['id'] = responseUser['_id'].toString();
    }
    if (responseUser['id'] != null && responseUser['id'] is! String) {
      responseUser['id'] = responseUser['id'].toString();
    }
    if ((responseUser['userName'] == null ||
            responseUser['userName'].toString().trim().isEmpty) &&
        responseUser['email'] != null) {
      responseUser['userName'] = responseUser['email'].toString().split('@')[0];
    }

    if (token.isEmpty || responseUser.isEmpty) {
      return ApiResponse<SignInResponse>(
        success: false,
        message: 'Sign in failed',
      );
    }

    await _client.setToken(token);
    await _client.setUserData(responseUser);
    await PushNotificationService().syncTokenIfAuthenticated();

    return ApiResponse<SignInResponse>(
      success: true,
      message: data['message']?.toString(),
      data: SignInResponse(
        token: token,
        user: User.fromJson(responseUser),
      ),
    );
  }

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
        return _storeSuccessfulSignIn(data);
      }

      print('❌ Sign in failed: ${data['message']}');
      return ApiResponse<SignInResponse>(
        success: false,
        message: data['message'] ?? 'Sign in failed',
        errors: data['errors'],
      );
    } catch (e, stackTrace) {
      print('❌ Sign in error: $e');
      print('❌ Stack trace: $stackTrace');
      return ApiResponse<SignInResponse>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<SignInResponse>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResponse<SignInResponse>(
          success: false,
          message: 'Google sign-in cancelled',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebaseResult =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = firebaseResult.user ?? _firebaseAuth.currentUser;

      final idToken = await firebaseUser?.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        return ApiResponse<SignInResponse>(
          success: false,
          message: 'Unable to obtain Firebase token for Google sign-in',
        );
      }

      final response = await _client.post(
        '/admin/firebase-config',
        body: {'idToken': idToken},
        includeAuth: false,
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final fallbackUser = <String, dynamic>{
          'id': firebaseUser?.uid ?? '',
          'email': firebaseUser?.email ?? googleUser.email,
          'userName': firebaseUser?.displayName ??
              googleUser.displayName ??
              googleUser.email.split('@').first,
          'role': 'user',
          'avatarUrl': firebaseUser?.photoURL ?? googleUser.photoUrl ?? '',
        };

        return _storeSuccessfulSignIn(data, fallbackUser: fallbackUser);
      }

      return ApiResponse<SignInResponse>(
        success: false,
        message: data['message']?.toString() ?? 'Google sign-in failed',
        errors: data['errors'],
      );
    } catch (e, stackTrace) {
      print('❌ Google sign-in error: $e');
      print('❌ Stack trace: $stackTrace');
      return ApiResponse<SignInResponse>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signUp(
    SignUpRequest request,
  ) async {
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
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data['message'] ?? 'Sign up failed',
        errors: data['errors'],
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      await PushNotificationService().unregisterTokenFromBackend();
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
