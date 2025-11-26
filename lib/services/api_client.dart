import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  String get baseUrl {
    const url = 'https://doorspital-backend.onrender.com/api';
    print('🔧 Base URL configured: $url');
    return url;
  }

  // Token management
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }

  // Headers
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    final currentBase = baseUrl;
    try {
      var uri = Uri.parse('$currentBase$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // Debug: Print the URL being called
      print('🌐 API Call: GET $uri');

      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: includeAuth),
      );

      // Debug: Print response
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return response;
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      throw Exception(
        'Unable to reach the server at $currentBase. '
        'Please check your internet connection or confirm the backend is running.\n\nDetails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      print('❌ Client Exception: $e');
      throw Exception('Network request failed: ${e.message}');
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final currentBase = baseUrl;
    try {
      final uri = Uri.parse('$currentBase$endpoint');

      // Debug: Print the URL being called
      print('🌐 API Call: POST $uri');
      if (body != null) {
        print('📤 Request Body: ${json.encode(body)}');
      }

      final response = await http.post(
        uri,
        headers: await _getHeaders(includeAuth: includeAuth),
        body: body != null ? json.encode(body) : null,
      );

      // Debug: Print response
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return response;
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      throw Exception(
        'Unable to reach the server at $currentBase. '
        'Please check your internet connection or confirm the backend is running.\n\nDetails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      print('❌ Client Exception: $e');
      throw Exception('Network request failed: ${e.message}');
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: await _getHeaders(includeAuth: includeAuth),
        body: body != null ? json.encode(body) : null,
      );

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        uri,
        headers: await _getHeaders(includeAuth: includeAuth),
      );

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      print('🌐 API Call: PATCH $uri');
      if (body != null) {
        print('📤 Request Body: ${json.encode(body)}');
      }

      final response = await http.patch(
        uri,
        headers: await _getHeaders(includeAuth: includeAuth),
        body: body != null ? json.encode(body) : null,
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Multipart request for file uploads
  Future<http.Response> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, List<http.MultipartFile>>? files,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = await _getHeaders(includeAuth: includeAuth);
      headers.remove('Content-Type'); // Let multipart set it
      request.headers.addAll(headers);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        request.files.addAll(files.values.expand((fileList) => fileList));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper to parse response
  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  // Helper to handle errors
  void handleError(http.Response response) {
    final data = parseResponse(response);
    final message = data['message'] ?? 'An error occurred';
    throw Exception(message);
  }
}
