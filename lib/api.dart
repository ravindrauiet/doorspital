// // lib/api.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// String get baseUrl =>
//     Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

// class SessionClient {
//   static final SessionClient _i = SessionClient._internal();
//   factory SessionClient() => _i;
//   SessionClient._internal();

//   final http.Client _client = http.Client();
//   String? _cookie; // e.g. "connect.sid=abc; Path=/; HttpOnly"

//   Future<http.Response> postJson(String path, Map<String, dynamic> body) async {
//     final res = await _client.post(
//       Uri.parse('$baseUrl$path'),
//       headers: {
//         'Content-Type': 'application/json',
//         if (_cookie != null) 'Cookie': _cookieHeaderValue(_cookie!),
//       },
//       body: jsonEncode(body),
//     );
//     _captureCookie(res);
//     return res;
//   }

//   Future<http.Response> get(String path) async {
//     final res = await _client.get(
//       Uri.parse('$baseUrl$path'),
//       headers: {if (_cookie != null) 'Cookie': _cookieHeaderValue(_cookie!)},
//     );
//     _captureCookie(res);
//     return res;
//   }

//   void clear() => _cookie = null;

//   void _captureCookie(http.Response res) {
//     final sc = res.headers['set-cookie'];
//     if (sc != null && sc.contains('connect.sid')) _cookie = sc;
//   }

//   String _cookieHeaderValue(String setCookie) {
//     final parts = setCookie.split(',');
//     final cookies = <String>[];
//     for (final p in parts) {
//       final pair = p.split(';').first.trim();
//       if (pair.contains('=')) cookies.add(pair);
//     }
//     return cookies.join('; ');
//   }
// }
