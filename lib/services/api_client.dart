import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Base URL configuration
  static const bool kUseLanIpForRealDevice = false;
  static const String kLanIp = '192.168.1.23';

  String get baseUrl {
    final host = _resolveHost();
    final url = 'http://$host:3000/api';
    print('🔧 Base URL configured: $url');
    return url;
  }

  String _resolveHost() {
    if (kUseLanIpForRealDevice) {
      print('🔧 Using LAN IP: $kLanIp');
      return kLanIp;
    }
    if (kIsWeb) {
      print('🔧 Using localhost (Web)');
      return 'localhost';
    }
    final host = switch (defaultTargetPlatform) {
      TargetPlatform.android => '10.0.2.2',
      TargetPlatform.iOS => '127.0.0.1',
      TargetPlatform.macOS => '127.0.0.1',
      TargetPlatform.windows => '127.0.0.1',
      TargetPlatform.linux => '127.0.0.1',
      _ => '127.0.0.1',
    };
    print('🔧 Platform: $defaultTargetPlatform, Using host: $host');
    return host;
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
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

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
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
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
      throw Exception('Connection failed. Please check:\n1. Backend server is running on port 3000\n2. You are using the correct host (10.0.2.2 for Android emulator, 127.0.0.1 for iOS)\n3. Your device/emulator can reach the server\n\nError: ${e.message}');
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
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
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
      throw Exception('Connection failed. Please check:\n1. Backend server is running on port 3000\n2. You are using the correct host (10.0.2.2 for Android emulator, 127.0.0.1 for iOS)\n3. Your device/emulator can reach the server\n\nError: ${e.message}');
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

